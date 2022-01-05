import 'package:ess_mobile/models/user_model.dart';
import 'package:ess_mobile/services/attendance_service.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/widgets/datepicker.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class LazyLoadingPage extends StatefulWidget {
  @override
  _LazyLoadingPageState createState() => _LazyLoadingPageState();
}

class _LazyLoadingPageState extends State<LazyLoadingPage> {
  final AttendanceService _attendanceService = AttendanceService();
  List<ActivityLogModel> logs = [];
  late List myList;
  ScrollController _scrollController = ScrollController();
  int _currentMax = 10;

  TextEditingController _filterDateStart = TextEditingController();
  TextEditingController _filterDateEnd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attendanceService.activitylogs({'limit':10, 'skip':0}).then((a) {
      if (a.status == ApiStatus.COMPLETED){
        if (a.data.data.length > 0){
          a.data.data.forEach((i){
            logs.add(i);
          });
          setState(() {});
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  _getMoreData() {
    _attendanceService.activitylogs({'limit':10, 'skip':_currentMax}).then((a) {
      if (a.status == ApiStatus.COMPLETED){
        if (a.data.data.length > 0){
          a.data.data.forEach((i){
            logs.add(i);
          });
          setState(() {
          });
        }
      }
    });
    _currentMax = _currentMax + 10;    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppActionButton(
        filter: (){
          showFilterDialog(context);
        },
      ),
      body:  ListView.builder(
        controller: _scrollController,
        
        itemExtent: 80,
        itemBuilder: (context, i) {

          String formattedTime = '';
          String formattedDate = '';
          if(logs.length > 0){
            var parsedDate = DateTime.parse(logs[i].createdDate.toString());
            formattedTime = DateFormat('HH:mm:ss').format(parsedDate); 
            formattedDate = DateFormat.yMMMMd().format(parsedDate);
          }
          
          if (i == logs.length) {
            return CupertinoActivityIndicator();
          }
          return ListTile(
            title: Text('$formattedDate $formattedTime', style: TextStyle(fontSize: 15)),
            subtitle: Text('${logs[i].activityType!.activityTypeName.toString()} - ${logs[i].location?.locationName.toString()}'),
          );
        },
        itemCount: logs.length,
      ),
    );
  }

  void showFilterDialog(BuildContext context) async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: space(10.0, <Widget>[
              Icon(Icons.filter),
              Text(
                AppLocalizations.of(context).translate('Filter'),
              ),
            ]),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autocorrect: false,
                    controller: _filterDateStart,
                    onTap: () {
                      AppDatePicker(context, setState).show(_filterDateStart);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    maxLines: 1,
                    validator: (value) => (value!.isEmpty || value.length < 1)
                        ? AppLocalizations.of(context).translate('ChooseDate')
                        : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('OpenDateFrom'),
                      icon: Icon(Icons.calendar_today),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    controller: _filterDateEnd,
                    onTap: () {
                      AppDatePicker(context, setState).show(_filterDateEnd);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    maxLines: 1,
                    validator: (value) => (value!.isEmpty || value.length < 1)
                        ? AppLocalizations.of(context).translate('ChooseDate')
                        : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('OpenDateTo'),
                      icon: Icon(Icons.calendar_today),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  )
                ],
              )
            ),
          ),

          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context).translate('Cancel'),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context).translate('Filter'),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () async {
                // _filterComplaints();
                Navigator.pop(context);
              },
            )
          ],

        );
      }
    );
  }
}