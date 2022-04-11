import 'dart:convert';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/leave_service.dart';
import 'package:ess_mobile/models/leave_model.dart';

class CalendarScreen extends StatefulWidget {
  final dynamic filterRequest;

  CalendarScreen(this.filterRequest);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final LeaveService _leaveService = LeaveService();

  List<Map<String, dynamic>> _leaveType = [];
  LeaveInfoModel _leaveInfo = LeaveInfoModel();
  Map<String, List<EventCalendar>> _leaves = {};
  Map<String, dynamic> _holidays = {};
  List<DataRow> _dataRows = <DataRow>[];

  ValueNotifier<List<EventCalendar>> _selectedEvents =
      ValueNotifier(<EventCalendar>[]);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = globals.today;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _totalReview = 0;
  int _totalRemainder = 0;
  bool _isLoading = true;

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

    _leaveService.leaveType(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          if (this.mounted) {
            setState(() {
              _leaveType = [];

              v.data.data.forEach((i) {
                _leaveType.add(i.toJson());
              });
            });
          }
        }
      }
    });

    _leaveService.leaveInfo(widget.filterRequest).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data != null) {
          if (this.mounted) {
            setState(() {
              _leaveInfo = v.data.data;
              if (_leaveInfo.maintenances!.length > 0) {
                int _periodStart = int.parse(globals.today.year.toString() +
                  globals.today.month.toString().padLeft(2, '0') +
                  globals.today.day.toString().padLeft(2, '0'));
                //int _periodFinish = int.parse(globals.today.year.toString() + '1231');

                _leaveInfo.maintenances!.forEach((v) {
                  int _periodEffective = int.parse(v.availabilitySchedule!.finish
                    .toString()
                    .substring(0, 10)
                    .replaceAll('-', ''));

                  if (v.isClosed == false) {
                    if (_periodEffective >= _periodStart) {
                      _dataRows.add(DataRow(
                        cells: <DataCell>[
                          DataCell(Text(v.year.toString())),
                          DataCell(Text(v.remainder.toString())),
                          DataCell(Text(v.description.toString())),
                        ],
                      ));

                      _totalRemainder += v.remainder!;
                    }
                  }
                });
              }
            });
          } 
        }
      }
    });

    _leaveService.calendar(widget.filterRequest).then((v) {
      if(v.status == ApiStatus.COMPLETED){
        if (this.mounted) {
          setState(() {
            var _response = v.data?.data;
            if (_response.leaves.length > 0) {
              _response.leaves.forEach((v) {
                if (v.schedule != null) {
                  DateTime _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(v.schedule.start, false)
                      .toLocal();
                  DateTime _finish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(v.schedule.finish, false)
                      .toLocal();

                  if (v.statusDescription.toString() == 'InReview') {
                    _totalReview++;
                  }

                  globals.getDaysInBeteween(_start, _finish).forEach((d) {
                    String _key = DateFormat('yyyy-MM-dd').format(d);

                    if (!_leaves.containsKey(_key)) {
                      _leaves[_key] = <EventCalendar>[];
                    }

                    _leaves[_key]!
                        .add(EventCalendar(json.encode(v.toJson())));
                  });
                }
              });
            }

            if (_response.holidays.length > 0) {
              _response.holidays.forEach((v) {
                DateTime _loggedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                    .parse(v.loggedDate.toString(), false)
                    .toLocal();
                String _key = DateFormat('yyyy-MM-dd').format(_loggedDate);

                if (!_holidays.containsKey(_key)) {
                  _holidays[_key] = <HolidayModel>[];
                }

                _holidays[_key].add(v);
              });
            }
            _isLoading = false;
          });
        }
      }
    });

    if (this.mounted) {
      setState(() {
        _selectedDay = _focusedDay;
        _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: _isLoading ? AppLoading() : _container(context),
    );
  }

  Widget _container(BuildContext context) {
    return Column(
      children: [ 
        _leaveRemainder(_leaveInfo, _totalReview),
        TableCalendar<EventCalendar>(
          firstDay: globals.firstDateTime,
          lastDay: globals.lastDateTime,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: _defaultBuilder,
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _selectedEvents.value = _getEventsForDay(focusedDay);

            /*DateTime _firstDayOfMonth =
                DateTime(focusedDay.year, focusedDay.month, 1);
            DateTime _lastDayOfMonth =
                DateTime(focusedDay.year, focusedDay.month + 1, 0);

            Map<String, dynamic> _dateRange = {
              'Start': _firstDayOfMonth.toLocal().toIso8601String(),
              'Finish': _lastDayOfMonth.toLocal().toIso8601String(),
            };*/
          },
        ),
        SizedBox(height: 5.0),
        Expanded(
          child: ValueListenableBuilder<List<EventCalendar>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  var item = json.decode(value[index].toString());

                  DateTime _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(item['Schedule']['Start'], false)
                      .toLocal();
                  DateTime _finish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(item['Schedule']['Finish'], false)
                      .toLocal();

                  String _scheduleDate =
                      DateFormat('EEEE, dd MMM yyyy').format(_start) +
                          ' - ' +
                          DateFormat('EEEE, dd MMM yyyy')
                              .format(_finish);

                  _leaveType.forEach((v) {
                    if (v['TypeId'].toString() ==
                        item['Type'].toString()) {
                      item['TypeDescription'] = v['Description'];
                    }
                  });

                  item['TypeDescription'] ??= item['Type'].toString();

                  List<List<Color>> _colors = [
                    [Colors.blueAccent, Colors.lightBlueAccent],
                    [Colors.teal, Colors.greenAccent],
                    [Colors.blueGrey, Colors.grey],
                    [Colors.redAccent, Colors.deepOrangeAccent],
                  ];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: _colors[item['Status']],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['TypeDescription'] ??= '-',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyText1,
                          ),
                          SizedBox(height: 5),
                          Text(
                            _scheduleDate,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .caption,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Status: ${(item['StatusDescription'] ??= '')}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Subtitute Employee: ${(item['SubtituteEmployeeName'] ??= '')}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Reason: ${(item['Reason'] ??= '')}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1,
                          ),
                        ],
                      ),
                      onTap: () => print('${value[index]}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _leaveRemainder(LeaveInfoModel _info, int _totalReview) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: space(5.0, <Widget>[
          Text(
            AppLocalizations.of(context).translate('LeaveRemainder'),
          ),
          InkWell(
            child: Container(
              color: Colors.teal,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 2.0,
                ),
                child: Text(
                  _totalRemainder.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Row(
                  children: space(10.0, <Widget>[
                    Icon(Icons.date_range),
                    Text(
                      AppLocalizations.of(context).translate('LeaveRemainder'),
                    ),
                  ]),
                ),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AppDataTable(
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Year'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Remainder'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('TypeLeave'),
                        ),
                      ),
                    ],
                    rows: _dataRows,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context, 'Close'),
                  ),
                  SizedBox(width: 8.0, height: 50.0),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Text(
            AppLocalizations.of(context).translate('WaitingForApproval'),
          ),
          InkWell(
            child: Container(
              color: Colors.deepOrangeAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 2.0,
                ),
                child: Text(
                  _totalReview.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, Routes.task),
          )
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();

    super.dispose();
  }

  List<EventCalendar> _getEventsForDay(DateTime day) {
    return _leaves[DateFormat('yyyy-MM-dd').format(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);

      // if (_selectedEvents.value.length > 0) {
      //   Map<String, dynamic> args =
      //       jsonDecode(_selectedEvents.value[0].toString());
      //
      //   args['readonly'] = true;
      //
      //   Navigator.pushNamed(
      //     context,
      //     Routes.leaveRequest,
      //     arguments: args,
      //   ).then((val) {
      //     setState(() {
      //       _calendar = _leaveService.calendar(widget.filterRequest);
      //     });
      //   });
      // }
    }
  }

  Widget? _defaultBuilder(
      BuildContext context, DateTime date1, DateTime date2) {
    if (date1.weekday == DateTime.sunday ||
        _holidays.containsKey(DateFormat('yyyy-MM-dd').format(date1))) {
      return Center(
        child: Text(date1.day.toString(), style: TextStyle(color: Colors.red)),
      );
    }

    return null;
  }
}

class EventCalendar {
  final String title;

  EventCalendar(this.title);

  @override
  String toString() => title;
}
