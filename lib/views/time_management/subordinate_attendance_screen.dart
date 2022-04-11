import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/models/time_management_model.dart';

class SubordinateAttendanceScreen extends StatefulWidget {
  @override
  _SubordinateAttendanceScreenState createState() =>
      _SubordinateAttendanceScreenState();
}

class _SubordinateAttendanceScreenState
    extends State<SubordinateAttendanceScreen> {
  final TimeManagementService _timeManagementService = TimeManagementService();

  Future<ApiResponse<dynamic>>? _subordinateAttendance;

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

    _subordinateAttendance = _timeManagementService
        .subordinateAttendance(globals.getFilterRequest(params: getValue));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('Subordinate')),
            Text(AppLocalizations.of(context).translate('Attendance')),
          ],
        ),
        toolbarHeight: 70,
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _subordinateAttendance = _timeManagementService
                  .subordinateAttendance(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _subordinateAttendance =
                _timeManagementService.subordinateAttendance(
                    globals.getFilterRequest(params: getValue));
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _subordinateAttendance,
        builder: (context, snapshot) {
          List<Widget> _children = <Widget>[];

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
                  Map<String, List<TimeAttendanceModel>> _dataMap = {};

                  _response.data.sort((a, b) {
                    return a.loggedDate
                        .toString()
                        .compareTo(b.loggedDate.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    DateTime _loggedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                        .parse(v.loggedDate.toString(), false)
                        .toLocal();
                    String _title =
                        DateFormat('EEEE, dd MMM yyyy').format(_loggedDate);

                    if (!_dataMap.containsKey(_title)) {
                      _dataMap[_title] = <TimeAttendanceModel>[];
                    }

                    _dataMap[_title]!.add(v);
                  });

                  bool _expanded = true;

                  _dataMap.forEach((k, v) {
                    _children.add(
                      _buildExpansionTile(context, k, v, _expanded),
                    );
                    _expanded = false;
                  });
                } else {
                  _children.add(
                    ListTile(
                      title: Center(child: Text('No Data Available')),
                    ),
                  );
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _subordinateAttendance =
                          _timeManagementService.subordinateAttendance(
                              globals.getFilterRequest(params: getValue));
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _subordinateAttendance =
                        _timeManagementService.subordinateAttendance(
                            globals.getFilterRequest(params: getValue));
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: _children,
                )
              : AppLoading();
        },
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    String title,
    List<TimeAttendanceModel> items,
    bool expanded,
  ) {
    List<DataRow> _dataRows = <DataRow>[];

    if (items.length > 0) {
      items.forEach((v) {
        _dataRows.add(DataRow(
          cells: _dataCells(v),
        ));
      });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.double_arrow,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          initiallyExpanded: expanded,
          children: [
            AppDataTable(
              columns: <DataColumn>[
                /* DataColumn(
                  label: Text(
                    AppLocalizations.of(context).translate('Project'),
                  ),
                ), */
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context).translate('Employee'),
                  ),
                ),
                /*DataColumn(
                  label: Text(
                    AppLocalizations.of(context).translate('EmployeeName'),
                  ),
                ),*/
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
              ],
              columnWidths: {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(70),
                2: FixedColumnWidth(70),
                3: FixedColumnWidth(55)
              },
              rows: _dataRows,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(TimeAttendanceModel item) {
    item.employeeID ??= '';
    item.employeeName ??= '';
    item.project ??= '';
    item.absenceCode ??= '';
    item.absenceCodeDescription ??= '';

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

    return <DataCell>[
      // DataCell(Text(item.project.toString())),
      DataCell(Text(item.employeeID.toString()+'\n'+item.employeeName.toString())),
      DataCell(Text(_scheduledDate.replaceAll('00:00', ''))),
      DataCell(Text(_actualLogedDate.replaceAll('00:00', ''))),
      DataCell(Text(item.absenceCodeDescription.toString())),
    ];
  }
}
