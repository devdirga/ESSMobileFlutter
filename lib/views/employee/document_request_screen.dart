import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/document_service.dart';
import 'package:ess_mobile/models/document_model.dart';

class DocumentRequestScreen extends StatefulWidget {
  @override
  _DocumentRequestScreenState createState() => _DocumentRequestScreenState();
}

class _DocumentRequestScreenState extends State<DocumentRequestScreen> {
  final DocumentService _documentService = DocumentService();

  Future<ApiResponse<dynamic>>? _documentRequests;

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

    _documentRequests =
        _documentService.documentRequests(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('DocumentRequest')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.documentRequestEntry,
          ).then((val) {
            setState(() {
              _documentRequests =
        _documentService.documentRequests(globals.getFilterRequest());
            });
          });
        },
        refresh: () {
          setState(() {
            _documentRequests =
        _documentService.documentRequests(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _documentRequests,
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
                      _documentRequests = _documentService
                          .documentRequests(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _documentRequests = _documentService
                        .documentRequests(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? AppDataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('DocType'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Description'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('CreatedDate'),
                      ),
                    ),
                    DataColumn(
                      label: Text(''),
                    ),
                   /* DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('ValidUntil'),
                      ),
                    ), */
                    /*DataColumn(
                      label: Text(
                        AppLocalizations.of(context)
                            .translate('ApprovalStatus'),
                      ),
                    ),*/
                  ],
                  rows: _dataRows,
                  columnWidths: {
                    0: FixedColumnWidth(140),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(90),
                    3: FixedColumnWidth(40),
                  },
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

  List<DataCell> _dataCells(DocumentRequestModel item) {
    item.documentType ??= '';
    item.description ??= '';

    DateTime _createdDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.createdDate!, false)
        .toLocal();

    /*DateTime _validDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.validDate!.finish!, false)
        .toLocal();*/

    List _status = ['Waiting for Approval', 'Verified', 'Rejected'];
    List<MaterialColor> _colors = [
      Colors.orange,
      Colors.green,
      Colors.red,
    ];
    List<IconData> _icons = [
      Icons.hourglass_bottom,
      Icons.check_circle,
      Icons.cancel,
    ];

    return <DataCell>[
      DataCell(Text(item.documentType.toString())),
      DataCell(Text(item.description.toString())),
      DataCell(Text(DateFormat('dd/MM/yyyy').format(_createdDate))),
      DataCell(Tooltip(
        message: _status[item.status!],
        preferBelow: false,
        child: CircleAvatar(
          radius: 14,
          backgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          child: Icon(_icons[item.status!], color: _colors[item.status!]),
        ),
      )),
      //DataCell(Text(DateFormat('dd MMM yyyy').format(_validDate))),
      /*DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _colors[item.status!],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _status[item.status!],
          style: TextStyle(color: Colors.white),
        ),
      )),*/
    ];
  }
}
