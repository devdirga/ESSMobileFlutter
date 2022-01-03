import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/document_service.dart';
import 'package:ess_mobile/models/document_model.dart';

class DocumentScreen extends StatefulWidget {
  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final DocumentService _documentService = DocumentService();

  Future<ApiResponse<dynamic>>? _documents;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().status != AppStatus.Authenticated) {
        context.read<AuthProvider>().signOut();

        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.login,
          ModalRoute.withName(Routes.login),
        );
      }
    });

    _documents = _documentService.documents(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Document')),
      ),
      main: _container(context),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _documents,
        builder: (context, snapshot) {
          List<DataRow> _dataRows = <DataRow>[];

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            var _response = snapshot.data?.data;

            switch (snapshot.data!.status) {
              case ApiStatus.LOADING:
                return AppLoading(
                  loadingMessage: snapshot.data!.message,
                );

              case ApiStatus.COMPLETED:
                if (_response.data.length > 0) {
                  _response.data.sort((a, b) {
                    return a.axid.toString().compareTo(b.axid.toString());
                  });

                  var indexData = 0;
                  _response.data.reversed.forEach((v) {
                    _dataRows.add(DataRow(
                      cells: _dataCells(v),
                      color: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Even rows will have a grey color.
                        if (indexData.isEven) {
                          return Colors.grey.withOpacity(0.3);
                        }
                        return Colors.white;
                         // Use default value for other states and odd rows.
                      })
                    ));
                    indexData++;
                  });
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _documents = _documentService
                          .documents(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _documents =
                        _documentService.documents(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? AppDataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(''),
                    ),
                    // DataColumn(
                    //   label: Text(''),
                    // ),
                    //DataColumn(
                    //  label: Text(
                    //    AppLocalizations.of(context).translate('DocumentType'),
                    //  ),
                    //),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Description'),
                      ),
                    ),
                    //DataColumn(
                    //  label: Text(
                    //    AppLocalizations.of(context).translate('UploadedDate'),
                    //  ),
                    //),
                    // DataColumn(
                    //   label: Text(
                    //     AppLocalizations.of(context).translate('Status'),
                    //   ),
                    // ),
                  ],
                  rows: _dataRows,
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(7)
                  }
                )
              : AppLoading();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(DocumentModel item) {
    item.description ??= '';

    //DateTime _createdDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
    //    .parse(item.createdDate!, false)
    //    .toLocal();

    return <DataCell>[
      DataCell(PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: space(10.0, <Widget>[
                Icon(
                  Icons.file_download,
                  color: (item.accessible!)
                      ? null
                      : Theme.of(context).disabledColor,
                ),
                Text(
                  AppLocalizations.of(context).translate('DownloadDocument'),
                  style: (item.accessible!)
                      ? null
                      : TextStyle(color: Theme.of(context).disabledColor),
                ),
              ]),
            ),
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            if (item.accessible!) {
              // globals.launchInBrowser(
              //   '${globals.apiUrl}/employee/document/download/${globals.appAuth.user?.id}/${item.axid}',
              // );

              Navigator.pushNamed(
                context,
                Routes.downloader,
                arguments: {
                  'name': 'Document (${item.documentType})',
                  'link':
                      '${globals.apiUrl}/ess/employee/MDownloadDocument/${globals.appAuth.user?.id}/${item.axid}/${item.filename}',
                },
              );
            }
          }
        },
      )),
      // DataCell(CircleAvatar(
      //   radius: 14,
      //   backgroundColor:
      //       Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
      //   child: Icon(_icons[item.status!], color: _colors[item.status!]),
      // )),
      // DataCell(Text(item.documentType.toString())),
      DataCell(Text(item.description.toString())),
      // DataCell(Text(DateFormat('dd MMM yyyy').format(_createdDate))),
      // DataCell(Container(
      //   padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      //   decoration: BoxDecoration(
      //     color: _colors[item.status!],
      //     borderRadius: BorderRadius.circular(10.0),
      //   ),
      //   child: Text(
      //     _status[item.status!],
      //     style: TextStyle(color: Colors.white),
      //   ),
      // )),
    ];
  }
}
