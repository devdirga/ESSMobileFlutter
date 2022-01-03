import 'package:ess_mobile/models/user_model.dart';
import 'package:ess_mobile/services/attendance_service.dart';
import 'package:ess_mobile/utils/api_response.dart';
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
      body:  ListView.builder(
        controller: _scrollController,
        
        itemExtent: 80,
        itemBuilder: (context, i) {

          String formattedTime = '';
          String formattedDate = '';
          if(logs.length > 0){
            var parsedDate = DateTime.parse(logs[i].createdDate.toString());
            formattedTime = DateFormat.jm().format(parsedDate); 
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
}