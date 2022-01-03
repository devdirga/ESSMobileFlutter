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
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/time_management_model.dart';

class TimeAttendanceScreen extends StatefulWidget {
  @override
  _TimeAttendanceScreenState createState() => _TimeAttendanceScreenState();
}

class _TimeAttendanceScreenState extends State<TimeAttendanceScreen> {
  final TimeManagementService _timeManagementService = TimeManagementService();
  final MasterService _masterService = MasterService();

  Future<ApiResponse<dynamic>>? _timeAttendance;
  List<String> _absenceCode = [];

  Map<String, dynamic> getValue = {
    'Start':
        DateTime.now().subtract(Duration(days: 8, hours: 7)).toIso8601String(),
    'Finish': DateTime.now().subtract(Duration(days: 1, hours: 7)).toIso8601String(),
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
            _timeAttendance = _timeManagementService
                .timeAttendance(globals.getFilterRequest(params: getValue));
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('MyAttendance')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _timeAttendance = _timeManagementService
                  .timeAttendance(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _timeAttendance = _timeManagementService
                .timeAttendance(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _timeAttendance,
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
                      _timeAttendance = _timeManagementService
                          .timeAttendance(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _timeAttendance = _timeManagementService
                        .timeAttendance(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? AppDataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Date'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Schedule'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('InOut'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Code'),
                      ),
                    ),
                    DataColumn(
                      label: Text(''),
                    )
                  ],
                  columnWidths: {
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(55),
                    4: FixedColumnWidth(55),
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

  List<DataCell> _dataCells(TimeAttendanceModel item) {
    item.project ??= '';
    item.absenceCode ??= '';
    item.absenceCodeDescription ??= '';

    DateTime _loggedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.loggedDate!, false)
        .toLocal();

    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.scheduledDate!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.scheduledDate!.finish!, false)
        .toLocal();
    String _scheduledDate = DateFormat('HH:mm').format(_scheduledDateStart) +
        ' - ' +
        DateFormat('HH:mm').format(_scheduledDateFinish);

    DateTime _actualLogedDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.actualLogedDate!.start!, false)
        .toLocal();
    DateTime _actualLogedDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.actualLogedDate!.finish!, false)
        .toLocal();
    String _actualLogedDate =
        DateFormat('HH:mm').format(_actualLogedDateStart) +
            ' - ' +
            DateFormat('HH:mm').format(_actualLogedDateFinish);

    TextStyle? _textStyle = TextStyle(
      color: (item.updateRequest == 1)
          ? Colors.grey
          : Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    return <DataCell>[
      // DataCell(Text(item.project.toString(), style: _textStyle)),
      DataCell(Text(DateFormat('EEEE, dd-MM-yyyy').format(_loggedDate),
          style: _textStyle)),
      //DataCell(Text(DateFormat('EEEE').format(_loggedDate), style: _textStyle)),
      DataCell(Text(_scheduledDate.replaceAll('00:00', ''), style: _textStyle)),
      DataCell(
          Text(_actualLogedDate.replaceAll('00:00', ''), style: _textStyle)),
      DataCell(Text(item.absenceCode.toString(), style: _textStyle)),
      DataCell((_absenceCode.contains(item.absenceCode.toString()))
          ? _dataActions(item)
          : Text('')),
    ];
  }

  dynamic _dataActions(TimeAttendanceModel item) {
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
              (item.action == 0 || item.action == 2)
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
                            AppLocalizations.of(context)
                                .translate('RecommendationAbsence'),
                          ),
                        ]),
                      ),
                      value: 2,
                    ),
              (item.action == 0 || item.action == 2)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
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
                                : TextStyle(
                                    color: Theme.of(context).disabledColor),
                          ),
                        ]),
                      ),
                      value: 4,
                    ),
            ],
      onSelected: (value) async {
        if (value == 0) {
          AppAlert(context).discard(
            title: AppLocalizations.of(context).translate('MyAttendance'),
            yes: () async {
              ApiResponse<dynamic> result = await _timeManagementService
                  .timeAttendanceDiscard(item.id.toString());

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _timeAttendance = _timeManagementService
                        .timeAttendance(globals.getFilterRequest());
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
          _item['Readonly'] = true;

          Navigator.pushNamed(
            context,
            Routes.recommendationAbsence,
            arguments: _item,
          ).then((val) {
            setState(() {
              _timeAttendance = _timeManagementService
                  .timeAttendance(globals.getFilterRequest());
            });
          });
        }

        if (value == 2) {
          Navigator.pushNamed(
            context,
            Routes.recommendationAbsence,
            arguments: item.toJson(),
          ).then((val) {
            setState(() {
              _timeAttendance = _timeManagementService
                  .timeAttendance(globals.getFilterRequest());
            });
          });
        }

        if (value == 4) {
          if (item.accessible!) {
            // globals.launchInBrowser(
            //   '${globals.apiUrl}/timemanagement/download/${globals.appAuth.user?.id}/${item.axRequestID}',
            // );

            Navigator.pushNamed(
              context,
              Routes.downloader,
              arguments: {
                'name':
                    'Document Verification (${item.absenceCodeDescription})',
                'link':
                    '${globals.apiUrl}/ess/timemanagement/MDownload/${globals.appAuth.user?.id}/${item.axRequestID}/${item.filename}',
              },
            );
          }
        }
      },
    );
  }
}
