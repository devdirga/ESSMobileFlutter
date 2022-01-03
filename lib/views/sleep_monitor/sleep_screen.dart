import 'dart:convert';
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
import 'package:ess_mobile/services/sleep_monitor_service.dart';
import 'package:ess_mobile/models/sleep_monitor_model.dart';

class SleepScreen extends StatefulWidget {
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final SleepMonitorService _sleepMonitorService = SleepMonitorService();

  Future<ApiResponse<dynamic>>? _sleepmonitor;

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

    _sleepmonitor =
        _sleepMonitorService.sleepmonitor(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('SleepMonitor')),
      ),
      main: _container(context),
      drawer: AppDrawer(),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.sleepMonitorEntry,
          ).then((val) {
            setState(() {
              _sleepmonitor =
                  _sleepMonitorService.sleepmonitor(globals.getFilterRequest());
            });
          });
        },
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _sleepmonitor = _sleepMonitorService
                  .sleepmonitor(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _sleepmonitor =
                _sleepMonitorService.sleepmonitor(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _sleepmonitor,
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
                    return a.actualSleep.start
                        .toString()
                        .compareTo(b.actualSleep.start.toString());
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
                      _sleepmonitor = _sleepMonitorService
                          .sleepmonitor(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _sleepmonitor = _sleepMonitorService
                        .sleepmonitor(globals.getFilterRequest());
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
                        AppLocalizations.of(context).translate('SleepingTime'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('WakeUpTime'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('NumberOfAwake'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('TotalAwake'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context)
                            .translate('TotalSleepTime'),
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

  List<DataCell> _dataCells(SleepMonitorModel item) {
    DateTime _sleepStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.actualSleep!.start!, false)
        .toLocal();
    DateTime _sleepFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.actualSleep!.finish!, false)
        .toLocal();

    return <DataCell>[
      DataCell(_dataActions(item)),
      DataCell(Text(DateFormat('dd MMM yyyy HH:mm').format(_sleepStart))),
      DataCell(Text(DateFormat('dd MMM yyyy HH:mm').format(_sleepFinish))),
      DataCell(Text(item.totalTimeAwakened.toString())),
      DataCell(Text(item.totalWakeUpHours.toString())),
      DataCell(Text(item.totalSleepHours.toString())),
    ];
  }

  dynamic _dataActions(SleepMonitorModel item) {
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
              (item.action == 2)
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
            ],
      onSelected: (value) async {
        if (value == 0) {
          AppAlert(context).discard(
            title: AppLocalizations.of(context).translate('SleepMonitor'),
            yes: () async {
              ApiResponse<dynamic> result = await _sleepMonitorService
                  .sleepmonitorDiscard(item.id.toString());

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _sleepmonitor = _sleepMonitorService
                        .sleepmonitor(globals.getFilterRequest());
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
            Routes.sleepMonitorEntry,
            arguments: _item,
          ).then((val) {
            setState(() {
              _sleepmonitor =
                  _sleepMonitorService.sleepmonitor(globals.getFilterRequest());
            });
          });
        }

        if (value == 2) {
          Navigator.pushNamed(
            context,
            Routes.sleepMonitorEntry,
            arguments: item.toJson(),
          ).then((val) {
            setState(() {
              _sleepmonitor =
                  _sleepMonitorService.sleepmonitor(globals.getFilterRequest());
            });
          });
        }

        if (value == 3) {
          AppAlert(context).delete(
            title: AppLocalizations.of(context).translate('SleepMonitor'),
            yes: (reason) async {
              ApiResponse<dynamic> result =
                  await _sleepMonitorService.sleepmonitorDelete(
                json.encode({
                  'id': item.id,
                  'employeeID': item.employeeID,
                  'reason': reason,
                }),
              );

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _sleepmonitor = _sleepMonitorService
                        .sleepmonitor(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }
            },
          );
        }
      },
    );
  }
}
