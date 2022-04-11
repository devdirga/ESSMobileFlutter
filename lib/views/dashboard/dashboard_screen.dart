
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/leave_service.dart';
//import 'package:ess_mobile/services/training_service.dart';
import 'package:ess_mobile/services/local_notification_service.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/services/common_service.dart';
import 'package:ess_mobile/models/leave_model.dart';
import 'package:ess_mobile/views/dashboard/agenda_items.dart';
//import 'package:ess_mobile/views/dashboard/medical_plafon.dart';
//import 'package:ess_mobile/views/dashboard/medical_record.dart';
import 'package:ess_mobile/views/dashboard/time_attendance.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LeaveService _leaveService = LeaveService();
  //final TrainingService _trainingService = TrainingService();
  final newVersion = NewVersion();
  final TimeManagementService _timeManagementService = TimeManagementService();
  final CommonService _commonService = CommonService();
  final AuthProvider _authProvider = AuthProvider();

  String _clockIn = '';
  String _clockOut = '';
  // String _totalTraining = '0';
  List<MaintenanceModel> _leaveInfo = [];
  dynamic _bannerFile;

  late FirebaseMessaging _messaging;

  void _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      globals.packageInfo = info;
    });
  }

  void _checkVersioning(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      int _checkVersion = globals.compareVersion(status.localVersion, status.storeVersion);
      if(_checkVersion == -1){    
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          allowDismissal: false
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _checkVersioning(newVersion);
    
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
    
    LocalNotificationService.initialize(context);

    _messaging = FirebaseMessaging.instance;
    _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _messaging.getToken().then((String? _token) async {
      Map<String, dynamic> fcmUserData = {
        'Username': globals.appAuth.user?.username,
        'FirebaseToken': _token.toString()
      };

      print(_token);

      ApiResponse<dynamic> result = await _commonService.updateUserToken(fcmUserData);

      if (result.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, result.message);
      }

      if (result.status == ApiStatus.COMPLETED) {
        //globals.chatAuthor = AuthorModel.fromJson(author);
      }
    });
    
    _messaging
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _refreshNotifBell();
        Navigator.pushNamed(context, Routes.notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _refreshNotifBell();
      Navigator.pushNamed(context, Routes.notification);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.display(message);
      _refreshNotifBell();
    });
        
        /*if (message.data.containsKey('module') &&
            message.data.containsKey('value')) {
          Navigator.pushReplacementNamed(context, Routes.notification);
          //final String module = message.data['module'];
          
          final MessageModel msg =
              MessageModel.fromJson(json.decode(message.data['value']));

          if (globals.currentRoute != '/chat') {
            if (msg.receiver.toString() == globals.chatAuthor.id.toString()) { 
              
            }
          }

          if (module != 'chat') {
            _commonService.taskActive(globals.getFilterRequest()).then((v) {
              if (v.status == ApiStatus.COMPLETED) {
                if (v.data.data.length > 0) {
                  if (this.mounted) {
                    setState(() {
                      globals.totalTask = v.data.data.length;
                    });
                  }
                }
              }
            });

            _commonService.getNotification(filterNotifRequest).then((v) {
              if (v.status == ApiStatus.COMPLETED) {
                if (v.data.data.length > 0) {
                  int _activity = 0;
                  //v.data.total = _activity;

                  v.data.data.forEach((i) {
                    if (i.read == false) {
                      _activity++;
                    }
                  });

                  if (this.mounted) {
                    setState(() {
                      globals.totalActivity = _activity;
                    });
                  }
                }
              }
            });
          }
        }
      }
    });*/

    _refreshNotifBell();
    _refreshData();

    /*
    _trainingService.trainingHistory(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          int _completed = 0;

          v.data.data.forEach((i) {
            if (i.trainingRegistration != null) {
              if (i.trainingRegistration.registrationStatusDescription ==
                  'Completed') {
                _completed++;
              }
            }
          });

          if (this.mounted) {
            setState(() {
              _totalTraining = _completed.toString();
            });
          }
        }
      }
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Dashboard')),
      ),
      main: _container(context),
      mainColor: Colors.transparent,
      mainPadding: EdgeInsets.all(0.0),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }

  Widget _container(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            (_bannerFile != null) ? _bannerAgenda() : Container(),
            Container(
              height: 200.0,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        _todayAttendance(),
                        _leaveRemainder(),
                        //_completedTraining(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //_leaveRemainder(),
            AgendaItems(),
            //MedicalPlafon(),
            //MedicalRecord(),
            TimeAttendance(),
          ],
        ),
      )
    );
  }

  Expanded _todayAttendance() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.teal, Colors.tealAccent.shade400],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).translate('TodayAttendance'),
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.subtitle1!.color,
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
            SizedBox(height: 10),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).translate('ClockIn')} ${_clockIn.toString()}',
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
            ),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).translate('ClockOut')} ${_clockOut.toString()}',
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Expanded _completedTraining() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.teal, Colors.greenAccent],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).translate('CompletedTraining'),
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.subtitle1!.color,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  child: Icon(Icons.navigate_next, color: Colors.white),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, Routes.training),
                ),
              ],
            ),
            Expanded(
              child: Text(
                _totalTraining.toString(),
                style: Theme.of(context).primaryTextTheme.headline4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  */
  
  Expanded _leaveRemainder() {
     return Expanded(
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).translate('LeaveRemainder'),
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  child: Icon(Icons.navigate_next, color: Colors.white),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, Routes.leave),
                ),
              ],
            ),
            ListView(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.all(0.0),
              children: <Widget>[
                for (var info in _leaveInfo)
                  if (info.isClosed == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${info.description.toString()}: ${info.remainder.toString()}',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        /*Text(
                          'You used ${(((info.rights! - info.remainder!) / info.rights!) * 100).toStringAsFixed(1).replaceAll('.0', '')}% of your leave rights',
                          style: TextStyle(color: Colors.white, fontSize: 12.0),
                        ),*/
                      ],
                    ),
              ],
            )
          ],
        ),
      )
    );
  }

  Container _bannerAgenda() {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Image.network(_bannerFile, fit: BoxFit.cover),
    );
  }

  void _refreshNotifBell(){
    Map<String, dynamic> _filterNotifRequest = {
      "Limit":0,
      "Offset":0,
      "Filter":""
    }; 

    _commonService.mTaskActive(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (this.mounted) {
          setState(() {
            globals.totalTask = v.data.data.length;
          });
        }
      }
    });

    _commonService.getNotification(globals.getFilterRequest(params: _filterNotifRequest)).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          int _activity = 0;
          //v.data.total = _activity;

          v.data.data.forEach((i) {
            if (i.read == false) {
              _activity++;
            }
          });

          if (this.mounted) {
            setState(() {
              globals.totalActivity = _activity;
            });
          }
        }
      }
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 4));
    _leaveService.leaveInfo(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data != null) {
          if (v.data.data.maintenances.length > 0) {
            if(this.mounted){
              setState(() {
                _leaveInfo = [];

                v.data.data.maintenances.forEach((i) {
                  _leaveInfo.add(i);
                });
              });
            }
          }
        }
      }
    });

    _timeManagementService
        .absenceImported(globals.getFilterRequest())
        .then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        String _inTime = '';
        String _outTime = '';
        if(v.data.data.length == 1){
          DateTime _actualIn = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(v.data.data[0].clock, false)
            .toLocal();
          _inTime = DateFormat('HH:mm').format(_actualIn); 
        }
        if(v.data.data.length == 2){
          DateTime _actualOut = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(v.data.data[1].clock, false)
            .toLocal();
          _outTime = DateFormat('HH:mm').format(_actualOut); 
        }
        if(this.mounted){
          setState(() {
            _clockIn = _inTime;
            _clockOut = _outTime;
          });
        }
      }
    });

    _timeManagementService.agenda(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          v.data.data.forEach((v) {
            if (_bannerFile == null) {
              if (v.agendaType == 1 && v.attachments.length > 0) {
                _bannerFile = v.attachments[0].pathUrl;
              }
            }
          });

          if (_bannerFile != null) {
            if (this.mounted) {
              setState(() {});
            }
          }
        }
      }
    });

    _authProvider.checkPasswordStatus(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if(v.data.message == true){
          AppSnackBar.warning(context, "Please change your password");
          Navigator.pushNamed(context, Routes.changePassword);
        }
      }
    });

    /*
    _commonService.getLatestVersion().then((v) async {
      if (v.data.data.length > 0){
        if(Platform.isAndroid){
          String _latest = v.data.data[0]['Version'];
          int _checkVersion = globals.compareVersion(globals.packageInfo.version, _latest);
          if(_checkVersion == -1){
            AppAlert(context).basicAlert(
              title: 'Version '+ _latest + ' is available.',
              desc: 'Your app version is '+ globals.packageInfo.version + '. Please download the latest version.',
              yes: () {
                Navigator.pushNamed(
                  context,
                  Routes.downloader,
                  arguments: {
                    'name': 'APK ($_latest)',
                    'link':
                        '${globals.apiUrl}/ess/administrator/download/android/${v.data.data[0]['Filename']}',
                  },
                );
              }
            );
            /*AppAlert(context).updateVersion();
            File getFile = await _commonService.getInstallerFile('Android', v.data.data[0]['Filename']); 
            if(await getFile.exists()){
              OpenFile.open(getFile.path);
            }*/
          }
        }

        if(Platform.isIOS){
          String _latest = v.data.data[1]['Version'];
          int _checkVersion = globals.compareVersion(globals.packageInfo.version, _latest);
          if(_checkVersion == -1){
            AppAlert(context).basicAlert(
              title: 'Version '+ _latest + ' is available.',
              desc: 'Your app version is '+ globals.packageInfo.version + '. Please download the latest version.',
              yes: () {
                Navigator.pushNamed(
                  context,
                  Routes.downloader,
                  arguments: {
                    'name': 'IPA ($_latest)',
                    'link':
                        '${globals.apiUrl}/ess/administrator/download/ios/${v.data.data[1]['Filename']}',
                  },
                );
              }
            );
            /*AppAlert(context).updateVersion();
            File getFile = await _commonService.getInstallerFile('iOS', v.data.data[1]['Filename']); 
            if(await getFile.exists()){
              OpenFile.open(getFile.path);
            }*/
          }
        }
      }
    }); */
  }

  @override
  void dispose() {
    super.dispose();
  }
}
