import 'package:ess_mobile/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/common_service.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final CommonService _commonService = CommonService();
  Future<ApiResponse<dynamic>>? _notifications;
  Map<String, dynamic> _filterNotifRequest = {
    "Limit":0,
    "Offset":0,
    "Filter":""
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

    _notifications = _commonService.getNotification(globals.getFilterRequest(params: _filterNotifRequest));

    if (this.mounted) {
      setState(() {
        globals.totalActivity = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Notification')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _notifications,
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
                  _response.data.sort((a, b) {
                    return a.timestamp
                        .toString()
                        .compareTo(b.timestamp.toString());
                  });

                  _response.data.reversed.forEach((v) {
				            _children.add(_buildExpansionTile(context, v));
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
                      _notifications = _commonService
                          .getNotification(globals.getFilterRequest(params: _filterNotifRequest));
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _notifications = _commonService
                        .getNotification(globals.getFilterRequest(params: _filterNotifRequest));
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
    NotificationModel items
  ) {

	DateTime _timeStamp = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(items.timestamp!, false)
            //.add(Duration(hours: 7))
            .toLocal(); 
	MaterialColor _colorStatus = items.read! ? Colors.grey : Colors.lightBlue; 
	
  
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ListTile(
			onTap: () =>  _updateNotifStat(items),
			title: Text(items.message.toString()),
			subtitle: Row(
			  crossAxisAlignment: CrossAxisAlignment.center,
			  children: <Widget>[
				Text(
				  timeago.format(_timeStamp),
				  style: TextStyle(fontSize: 12),
				)
			  ],
			),
			trailing: Icon(Icons.check_circle, color: _colorStatus),
		  )
      ),
    );
  }

  void _updateNotifStat(NotificationModel item) async{
    if(item.read == false){
      item.read = true;

      ApiResponse<dynamic> result = await _commonService.setReadNotification(item.toJson());
      if (result.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, result.message);
      }

      if (result.status == ApiStatus.COMPLETED) {
        if (result.data.statusCode == 200) {
          if(item.actions!.length > 0){
            switch(item.actions![0]){
              case 'open_leave': 
                Navigator.pushNamed(context, Routes.leave);
                break;
              case 'open_time_management': 
                Navigator.pushNamed(context, Routes.timeAttendance);
                break;
              case 'open_employee_family': 
                Navigator.pushNamed(context, Routes.family);
                break;
              case 'open_employee_certificate': 
                Navigator.pushNamed(context, Routes.certificate);
                break;
              default: 
                break;
            }
          }
          else{
            setState(() {
              _notifications = _commonService
                  .getNotification(globals.getFilterRequest(params: _filterNotifRequest));
            });
          }
        }

        if (result.data.statusCode == 400) {
          AppSnackBar.danger(context, result.data.message.toString());
          setState(() {});
        }
      }
      else{
        if(item.actions!.length > 0){
          switch(item.actions![0]){
            case 'open_leave': 
              Navigator.pushNamed(context, Routes.leave);
              break;
            case 'open_time_management': 
              Navigator.pushNamed(context, Routes.timeAttendance);
              break;
            case 'open_employee_family': 
              Navigator.pushNamed(context, Routes.family);
              break;
            case 'open_employee_certificate': 
              Navigator.pushNamed(context, Routes.certificate);
              break;
            default: 
              break;
          }
        }
        else{
          setState(() {
            _notifications = _commonService
                .getNotification(globals.getFilterRequest(params: _filterNotifRequest));
          });
        }
      }
    }
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}