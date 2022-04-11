import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/complaint_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/ticket_category_model.dart';

class TicketCategoriesScreen extends StatefulWidget {
  @override
  _TicketCategoriesScreenState createState() => _TicketCategoriesScreenState();
}

class _TicketCategoriesScreenState extends State<TicketCategoriesScreen> {
  final ComplaintService _complaintService = ComplaintService();
  final MasterService _masterService = MasterService();

  Future<ApiResponse<dynamic>>? _categories;
  List<String> _absenceCode = [];

  Map<String, dynamic> getValue = {
    'Start': globals.today.subtract(Duration(
      days: 7,
      hours: globals.today.hour, 
      minutes: globals.today.minute, 
      seconds: globals.today.second, 
      milliseconds: globals.today.millisecond, 
      microseconds: globals.today.microsecond
    )).toIso8601String(),
    'Finish': globals.today.toIso8601String(),
  };

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

    _masterService.absenceCode().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _absenceCode = [];

          v.data.data.forEach((i) {
            if (i.isEditable) {
              _absenceCode.add(i.idField);
            }
          });
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _categories = _complaintService
                .ticketCategories();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('TicketCategory')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _categories = _complaintService
                .ticketCategories();
            });
          });
        },
        refresh: () {
          setState(() {
            _categories = _complaintService
                .ticketCategories();
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _categories,
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
                      _categories = _complaintService
                          .complaints(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _categories = _complaintService
                      .ticketCategories();
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
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Subject'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Type'),
                      ),
                    ),
                  ],
                  columnWidths: {
                    0: FixedColumnWidth(55),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(105),
                  },
                  rows: _dataRows,
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

  List<DataCell> _dataCells(TicketCategoryModel item) {
    /*item.project ??= '';
    item.absenceCode ??= '';
    item.absenceCodeDescription ??= '';*/
     
    TextStyle? _textStyle = TextStyle(
      color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

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
                Icon(Icons.remove_red_eye),
                Text(
                  AppLocalizations.of(context).translate('ShowDetail'),
                ),
              ]),
            ),
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            Map<String, dynamic> _item = item.toJson();
            _item['Readonly'] = true;

            Navigator.pushNamed(
              context,
              Routes.complaintEntry,
              arguments: _item,
            ).then((val) {
              setState(() {
                _categories = _complaintService.complaints(globals.getFilterRequest());
              });
            });
          }
        },
      )),
      DataCell(Text(item.name.toString(), style: _textStyle)),
      DataCell(Text(item.contacts![0].email.toString(), style: _textStyle)),
      //DataCell(Text(DateFormat('EEEE').format(_loggedDate), style: _textStyle)),
      //DataCell(Text(_scheduledDate.replaceAll('00:00', ''), style: _textStyle)),
      
    ];
  }
}
