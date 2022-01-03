import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/travel_service.dart';
import 'package:ess_mobile/models/travel_model.dart';

class TravelScreen extends StatefulWidget {
  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final TravelService _travelService = TravelService();

  Future<ApiResponse<dynamic>>? _travel;

  // List<String> _type = [];
  // List<String> _status = [];

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

    // _masterService.travelType().then((v) {
    //   if (v.status == ApiStatus.COMPLETED) {
    //     if (v.data.data.length > 0) {
    //       _type = v.data.data;
    //     }
    //   }
    // });
    //
    // _masterService.travelStatus().then((v) {
    //   if (v.status == ApiStatus.COMPLETED) {
    //     if (v.data.data.length > 0) {
    //       _status = v.data.data;
    //     }
    //   }
    // });

    _travel = _travelService.travel(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Travel')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.travelRequest,
          ).then((val) {
            setState(() {
              _travel = _travelService.travel(globals.getFilterRequest());
            });
          });
        },
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _travel =
                  _travelService.travel(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _travel = _travelService.travel(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _travel,
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

                  _response.data.reversed.forEach((v) {
                    _dataRows.add(DataRow(
                      cells: _dataCells(v),
                    ));
                  });
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _travel =
                          _travelService.travel(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _travel = _travelService.travel(globals.getFilterRequest());
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
                        AppLocalizations.of(context).translate('Schedule'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('ID'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Origin'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Destination'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Purpose'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Status'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('SPPD'),
                      ),
                    ),
                  ],
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

  List<DataCell> _dataCells(TravelModel item) {
    item.travelID ??= '';
    item.origin ??= '';
    item.destination ??= '';
    item.travelPurposeDescription ??= '';

    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();

    String _scheduledDate = '';

    if (DateFormat('dd MMM yyyy').format(_scheduledDateStart) ==
        DateFormat('dd MMM yyyy').format(_scheduledDateFinish)) {
      if (DateFormat('HH:mm').format(_scheduledDateStart) ==
          DateFormat('HH:mm').format(_scheduledDateFinish)) {
        _scheduledDate =
            DateFormat('EEEE, dd MMM yyyy').format(_scheduledDateStart) +
                ' at ' +
                DateFormat('HH:mm').format(_scheduledDateStart);
      } else {
        _scheduledDate =
            DateFormat('EEEE, dd MMM yyyy').format(_scheduledDateStart) +
                ' at ' +
                DateFormat('HH:mm').format(_scheduledDateStart) +
                ' - ' +
                DateFormat('HH:mm').format(_scheduledDateFinish);
      }
    } else {
      _scheduledDate = DateFormat('EEEE, dd MMM yyyy HH:mm')
              .format(_scheduledDateStart) +
          '\n' +
          DateFormat('EEEE, dd MMM yyyy HH:mm').format(_scheduledDateFinish);
    }

    List _reqStatus = ['Created', 'Revision', 'Canceled', 'Verified', 'Closed'];
    List<MaterialColor> _reqColors = [
      Colors.blueGrey,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.indigo,
    ];

    List _sppdStatus = ['Created', 'Rejected', 'Approved', 'Approval'];
    List<MaterialColor> _sppdColors = [
      Colors.blueGrey,
      Colors.red,
      Colors.green,
      Colors.orange,
    ];

    int _sppd = 0;

    if (item.sppd != null) {
      if (item.sppd!.length > 0) {
        _sppd = item.sppd![0].status!;
      }
    }

    return <DataCell>[
      DataCell(_dataActions(item)),
      DataCell(Text(_scheduledDate.replaceAll('00:00', ''))),
      DataCell(Text(item.travelID.toString())),
      DataCell(Text(item.origin.toString())),
      DataCell(Text(item.destination.toString())),
      DataCell(Text(item.travelPurposeDescription.toString())),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _reqColors[item.travelRequestStatus!],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _reqStatus[item.travelRequestStatus!],
          style: TextStyle(color: Colors.white),
        ),
      )),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _sppdColors[_sppd],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _sppdStatus[_sppd],
          style: TextStyle(color: Colors.white),
        ),
      )),
    ];
  }

  dynamic _dataActions(TravelModel item) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).hintColor,
      ),
      itemBuilder: (context) => (item.updateRequest == 1)
          ? [
              PopupMenuItem(
                child: Row(
                  children: space(10.0, <Widget>[
                    Icon(Icons.hourglass_bottom),
                    Text(
                      AppLocalizations.of(context).translate('WaitingApproval'),
                    ),
                  ]),
                ),
                value: -1,
              ),
            ]
          : [
              (item.action == 0 || item.action == 2 || globals.hidden)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.edit_off),
                          Text(
                            AppLocalizations.of(context)
                                .translate('DiscardChanges'),
                          ),
                        ]),
                      ),
                      value: 0,
                    ),
              // PopupMenuItem(
              //   child: Row(
              //     children: space(10.0, <Widget>[
              //       Icon(Icons.remove_red_eye),
              //       Text(
              //         AppLocalizations.of(context).translate('ViewData')_,
              //       ),
              //     ]),
              //   ),
              //   value: 1,
              // ),
              (item.action == 2 || globals.hidden)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.edit_sharp),
                          Text(
                            AppLocalizations.of(context).translate('EditData'),
                          ),
                        ]),
                      ),
                      value: 2,
                    ),
              (item.action == 2 || globals.hidden)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.delete_sharp),
                          Text(
                            AppLocalizations.of(context)
                                .translate('DeleteData'),
                          ),
                        ]),
                      ),
                      value: 3,
                    ),
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
                      AppLocalizations.of(context)
                          .translate('DownloadDocument'),
                      style: (item.accessible!)
                          ? null
                          : TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  ]),
                ),
                value: 4,
              ),
            ],
      onSelected: (value) async {
        if (value == 0) {
          AppAlert(context).discard(
            title: AppLocalizations.of(context).translate('Travel'),
            yes: () async {
              ApiResponse<dynamic> result =
                  await _travelService.travelDiscard(item.id.toString());

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _travel = _travelService.travel(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }
            },
          );
        }

        if (value == 1) {
          Map<String, dynamic> _item = item.toJson();
          _item['readonly'] = true;

          Navigator.pushNamed(
            context,
            Routes.travelRequest,
            arguments: _item,
          ).then((val) {
            setState(() {
              _travel = _travelService.travel(globals.getFilterRequest());
            });
          });
        }

        if (value == 2) {
          Navigator.pushNamed(
            context,
            Routes.travelRequest,
            arguments: item.toJson(),
          ).then((val) {
            setState(() {
              _travel = _travelService.travel(globals.getFilterRequest());
            });
          });
        }

        if (value == 3) {
          AppAlert(context).delete(
            title: AppLocalizations.of(context).translate('Travel'),
            yes: (reason) async {
              Map<String, dynamic> body = {
                'id': item.axid,
                'employeeID': item.employeeID,
                'reason': reason,
              };

              ApiResponse<dynamic> result =
                  await _travelService.travelDelete(body);

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _travel = _travelService.travel(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }
            },
          );
        }

        if (value == 4) {
          if (item.accessible!) {
            // globals.launchInBrowser(
            //   '${globals.apiUrl}/travel/download/${globals.appAuth.user?.id}/${item.axid}',
            // );

            Navigator.pushNamed(
              context,
              Routes.downloader,
              arguments: {
                'name': 'Travel Document (${item.travelPurposeDescription})',
                'link':
                    '${globals.apiUrl}/travel/download/${globals.appAuth.user?.id}/${item.axid}',
              },
            );
          }
        }
      },
    );
  }
}
