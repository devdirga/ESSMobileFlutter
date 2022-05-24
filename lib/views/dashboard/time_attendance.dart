import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/models/time_management_model.dart';

class TimeAttendance extends StatefulWidget {
  @override
  _TimeAttendanceState createState() => _TimeAttendanceState();
}

class _TimeAttendanceState extends State<TimeAttendance> {
  final TimeManagementService _timeManagementService = TimeManagementService();

  Future<ApiResponse<dynamic>>? _timeAttendance;

  Map<String, dynamic> getValue = {
    'Start': globals.today.subtract(Duration(
      days: 8,
      hours: globals.today.hour, 
      minutes: globals.today.minute, 
      seconds: globals.today.second, 
      milliseconds: globals.today.millisecond, 
      microseconds: globals.today.microsecond
    )).toIso8601String(),
    'Finish': globals.today.subtract(Duration(
      days: 1,
      hours: globals.today.hour, 
      minutes: globals.today.minute, 
      seconds: globals.today.second, 
      milliseconds: globals.today.millisecond, 
      microseconds: globals.today.microsecond
    )).toIso8601String(),
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {});

    _timeAttendance =
        _timeManagementService.timeAttendance(globals.getFilterRequest(params: getValue));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('DailyAttendances'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.navigate_next, color: Colors.white),
                    onTap: () => Navigator.pushReplacementNamed(
                        context, Routes.timeAttendance),
                  ),
                ],
              ),
            ),
          ),
          _dataTable(context),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _dataTable(BuildContext context) {
    return FutureBuilder<ApiResponse<dynamic>>(
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

                int i = 0;

                _response.data.reversed.forEach((v) {
                  if (i < 7) {
                    _dataRows.add(DataRow(
                      cells: _dataCells(v)
                    ));
                  }

                  i++;
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
                ],
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FixedColumnWidth(90),
                  2: FixedColumnWidth(90),
                  3: FixedColumnWidth(55)
                },
                rows: _dataRows,
                headingColor:
                    Theme.of(context).primaryColorDark.withOpacity(0.6),
                headingTextStyle: Theme.of(context).primaryTextTheme.caption,
              )
            : AppLoading();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(TimeAttendanceModel item) {
    item.project ??= '';

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

    return <DataCell>[
      DataCell(Text(DateFormat('EEEE,\ndd-MM-yyyy').format(_loggedDate))),
      DataCell(Text(_scheduledDate.replaceAll('00:00', ''))),
      DataCell(Text(_actualLogedDate.replaceAll('00:00', ''))),
      DataCell(Text(item.absenceCode.toString())),
    ];
  }
}
