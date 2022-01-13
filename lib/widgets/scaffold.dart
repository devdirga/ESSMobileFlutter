import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/background.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/providers/theme_provider.dart';
//import 'package:ess_mobile/services/resume_service.dart';

class AppScaffold extends StatefulWidget {
  final NavBar? navBar;
  final Widget? main;
  final Color? mainColor;
  final EdgeInsetsGeometry? mainPadding;
  final AppDrawer? drawer;
  final Widget? actionButton;
  final FloatingActionButtonLocation? actionButtonLocation;
  final BottomNavigationBar? navigationBar;
  final Color? backgroundColor;

  AppScaffold({
    Key? key,
    this.navBar,
    this.main,
    this.mainColor,
    this.mainPadding,
    this.drawer,
    this.actionButton,
    this.actionButtonLocation,
    this.navigationBar,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  //final ResumeService _resumeService = ResumeService();
  final AuthProvider _authProvider = AuthProvider();

  bool _darkMode = false;
  String _profilePict = (globals.appAuth.user != null &&
          globals.appAuth.user!.userData != null && globals.appAuth.user!.userData!.profilePicture != null)
      ? globals.appAuth.user!.userData!.profilePicture.toString()
      : '';

  Timer? _keepAliveTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _darkMode = context.read<ThemeProvider>().isDarkModeOn;

      if (ModalRoute.of(context)?.settings.name != null) {
        globals.currentRoute = ModalRoute.of(context)!.settings.name.toString();
      }
    });

    _initializeTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.drawer != null) {
          if (ModalRoute.of(context)?.settings.name != '/dashboard') {
            Navigator.pushReplacementNamed(context, Routes.dashboard);
          } else {
            _confirmSignOut(context);
          }
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: _handleUserInteraction,
        onPanDown: _handleUserInteraction,
        child: Scaffold(
          appBar: (widget.navBar != null) ? _appBar(context) : null,
          body: (widget.backgroundColor != null)
              ? widget.main
              : Stack(
                  children: <Widget>[
                    AppBackground(),
                    Padding(
                      padding: (widget.mainPadding != null)
                          ? widget.mainPadding!
                          : EdgeInsets.symmetric(vertical: 10.0),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 0.0,
                        color: (widget.mainColor != null)
                            ? widget.mainColor!
                            : Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints.expand(),
                          child: widget.main,
                        ),
                      ),
                    ),
                  ],
                ),
          drawer: (widget.drawer != null) ? widget.drawer : null,
          floatingActionButton: widget.actionButton,
          floatingActionButtonLocation: widget.actionButtonLocation,
          bottomNavigationBar: widget.navigationBar,
          backgroundColor: (widget.backgroundColor != null)
              ? widget.backgroundColor
              : Theme.of(context).backgroundColor,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      titleSpacing: 0.0,
      title: widget.navBar?.title,
      bottom: widget.navBar?.bottom,
      toolbarHeight: widget.navBar?.toolbarHeight,
      actions: (widget.navBar?.actions != null)
          ? widget.navBar?.actions
          : context.read<AuthProvider>().status == AppStatus.Authenticated ?
            <Widget>[
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.library_add_check_sharp),
                    padding: EdgeInsets.only(top: 16),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routes.task);
                    },
                  ),
                  (globals.totalTask == 0)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(top: 8, left: 0),
                          child: CircleAvatar(
                            child: Text(
                              globals.totalTask.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            backgroundColor: Colors.red,
                            maxRadius: 11,
                          ),
                        ),
                ],
              ),
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.notifications),
                    padding: EdgeInsets.only(top: 16),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, Routes.notification);
                    },
                  ),
                  (globals.totalActivity == 0)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(top: 8, left: 0),
                          child: CircleAvatar(
                            child: Text(
                              globals.totalActivity.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            backgroundColor: Colors.red,
                            maxRadius: 11,
                          ),
                        ),
                ],
              ),
              PopupMenuButton(
                icon: Icon(Icons.account_circle),
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'userName',
                    child: Row(
                      children: space(10.0, <Widget>[
                        (_profilePict != '')
                            ? CircleAvatar(
                                radius: 20.0,
                                //backgroundImage: Image.memory(base64Decode(_profilePict)).image,
                                backgroundImage: MemoryImage(base64Decode(_profilePict)),
                                backgroundColor: Colors.transparent,
                              )
                            : CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.grey.shade300,
                              ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(globals.appAuth.user!.fullName.toString()),
                              Text(
                                globals.appAuth.user!.email.toString(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'changePassword',
                    child: Row(
                      children: space(10.0, <Widget>[
                        Icon(
                          Icons.lock,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .translate('ChangePassword'),
                        ),
                      ]),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'themeMode',
                    child: Row(
                      children: space(10.0, <Widget>[
                        Icon(
                          Icons.brightness_medium_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        (_darkMode)
                            ? Text(AppLocalizations.of(context)
                                .translate('DarkModeOff'))
                            : Text(AppLocalizations.of(context)
                                .translate('DarkModeOn')),
                      ]),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: space(10.0, <Widget>[
                        Icon(
                          Icons.logout,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('Logout'),
                        ),
                      ]),
                    ),
                  ),
                ],
                onSelected: (index) async {
                  switch (index) {
                    case 'userName':
                      //_changeImageProfile(context);
                      break;
                    case 'changePassword':
                      Navigator.pushNamed(
                        context,
                        Routes.changePassword,
                      );
                      /*AppAlert(context).changePassword(
                        yes: (String psw, String newPsw) async {
                          if (psw.length < 6 || newPsw.length < 6) {
                            AppSnackBar.danger(context,
                                'Password must be at least 6 characters long.');
                          } else {
                            Map<String, dynamic> body = {
                              'EmployeeID': globals.appAuth.user!.id.toString(),
                              'Password': psw.trim(),
                              'NewPassword': newPsw.trim(),
                            };

                            ApiResponse<dynamic> result =
                                await _authProvider.changePassword(body);

                            if (result.status == ApiStatus.ERROR) {
                              AppSnackBar.danger(context, result.message);
                            }

                            if (result.status == ApiStatus.COMPLETED) {
                              if (result.data.statusCode == 200) {
                                if (result.data.data['Success']) {
                                  AppSnackBar.success(
                                      context, result.data.data['Message']);
                                } else {
                                  AppSnackBar.danger(
                                      context, result.data.data['Message']);
                                }
                              } else {
                                AppSnackBar.danger(
                                    context, result.data.data['Message']);
                              }
                            }
                          }
                        },
                      );*/
                      break;
                    case 'themeMode':
                      Provider.of<ThemeProvider>(context, listen: false)
                          .updateTheme(!_darkMode);
                      _darkMode = !_darkMode;
                      break;
                    case 'logout':
                      _confirmSignOut(context);
                      break;
                  }
                },
              ),
              SizedBox(width: 5.0),
            ]
            : 
            <Widget>[],
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  void _confirmSignOut(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to exit?'),
          content:
              Text('Click Yes to continue, or Cancel stay on the current page'),
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
                AppLocalizations.of(context).translate('Yes'),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () async {
                _exitApp();
              },
            ),
          ],
        );
      },
    );
  }

  /*
  void _changeImageProfile(BuildContext context) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();

      ApiResponse<dynamic> upload = await _resumeService.profilePicture({
        'id': globals.appAuth.user!.id.toString(),
        'file': base64Encode(bytes),
        'fileName': result.name,
      });

      if (upload.status == ApiStatus.COMPLETED) {
        if (upload.data.statusCode == 200) {
          if (upload.data.data != null) {
            setState(() {
              _profilePict = upload.data.data['path'] +
                  '?v=${DateTime.now().millisecond.toString()}';
              globals.appAuth.user!.profilePictUrl = _profilePict;
            });
          }
        }
      }
    }
  }
  */

  void _initializeTimer() {
    if (this.mounted) {
      if (_keepAliveTimer != null) {
        _keepAliveTimer?.cancel();
      }

      _keepAliveTimer = Timer(globals.inactivityTimeout, _exitApp);
    }
  }

  void _exitApp() {
    if (this.mounted) {
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;

      Provider.of<AuthProvider>(context, listen: false).signOut();

      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        ModalRoute.withName(Routes.login),
      );
      /*
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }

      if (Platform.isIOS) {
        exit(0);
      }*/
    }
  }

  void _handleUserInteraction([_]) {
    _initializeTimer();
  }
}

class NavBar {
  Widget? title;
  double? toolbarHeight;
  PreferredSizeWidget? bottom;
  List<Widget>? actions;

  NavBar({this.title, this.toolbarHeight, this.bottom, this.actions});

  NavBar.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    bottom = json['bottom'];
    toolbarHeight = json['toolbarHeight'];
    actions = json['actions'];
  }
}
