import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/validate.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/biometric_auth.dart';
import 'package:ess_mobile/utils/shared_preference.dart';
import 'package:ess_mobile/widgets/logo.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/textfield.dart';
import 'package:ess_mobile/widgets/button.dart';
import 'package:ess_mobile/widgets/background.dart';
import 'package:ess_mobile/widgets/copyright.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/services/common_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final CommonService _commonService = CommonService();
  AppSharedPreference _sharedPrefsHelper = AppSharedPreference(); 
  TextEditingController _idController = TextEditingController(text: '');
  TextEditingController _passwordController = TextEditingController(text: '');
  
  bool _obscureText = true;
  String? signInData;
  int loginType = 0;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      globals.packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().status == AppStatus.Registered) {
        context.read<AuthProvider>().signOut();

        AppSnackBar.success(
          context,
          'You have successfully registered. Please login to your account',
        );
      }
    });

    _sharedPrefsHelper.loginData.then((value) {
      setState(() {
        signInData = value;
      });
    });

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
    }); 
      
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AppBackground(
            height: 500,
            shapeColor: Theme.of(context).backgroundColor,
          ),
          AppCopyright(),
          _buildForm(context),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
    );
  }

  Widget _buildForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Column(children: <Widget>[
                AppLogo(size: 80),
                SizedBox(height: 10),
                Text(
                  'ESS v' + globals.packageInfo.version,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 0.0,
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.0),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AppTextField(
                        prefixIcon: Icons.account_circle,
                        labelText: AppLocalizations.of(context)
                            .translate('EmployeeID'),
                        controller: _idController,
                        validator: (String? value) {
                          return Validate.requiredField(
                            value!,
                            'Employee ID is required.',
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      AppTextField(
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          onPressed: _toggle,
                          icon: _obscureText ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                        ),
                        labelText:
                            AppLocalizations.of(context).translate('Password'),
                        controller: _passwordController,
                        validator: (String? value) {
                          return Validate.requiredField(
                            value!,
                            'Password is required.',
                          );
                        },
                        obscureText: _obscureText,
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('ForgotPassword'),
                            style:
                                TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(Routes.forgotPassword);
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      authProvider.status == AppStatus.Authenticating && loginType == 1
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : AppButton(
                              label: AppLocalizations.of(context)
                                  .translate('SignIn'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  
                                  setState(() {
                                    loginType = 1;
                                  });

                                  ApiResponse<dynamic> result =
                                      await authProvider.signIn(
                                    _idController.text,
                                    _passwordController.text,
                                  );

                                  if (result.status == ApiStatus.ERROR) {
                                    AppSnackBar.danger(context, result.message);
                                  }

                                  if (result.status == ApiStatus.COMPLETED) {
                                    if (authProvider.auth.success == true) {
                                      globals.appAuth = authProvider.auth;
                                      globals.totalTask = 0;
                                      globals.totalActivity = 0;

                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/',
                                      );
                                    } else {
                                      if (authProvider.auth.message != null) {
                                        AppSnackBar.danger(
                                          context,
                                          authProvider.auth.message,
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                            ),
                      SizedBox(height: 20),
                      signInData != null ? _buildBiometricLogin(context) : Center(),
                      SizedBox(height: 50),
                      Text(
                        AppLocalizations.of(context)
                            .translate('DontHaveAccount'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('CreateAccount'),
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.register);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricLogin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return authProvider.status == AppStatus.Authenticating && loginType == 2
      ? Center(
        child: CircularProgressIndicator(),
      ) : AppButton(
        label: AppLocalizations.of(context)
            .translate('BiometricSignIn'),
        onPressed: () async {
          bool bioAuth = await BioAuthentication.authenticateWithBiometrics();

          if(bioAuth){
            String? loginData = await _sharedPrefsHelper.loginData;
            if (loginData != null) {
              setState(() {
                loginType = 2;
              });
              final Map<String, dynamic> jsonResponse = jsonDecode(loginData);
              ApiResponse<dynamic> result =
                await authProvider.signIn(
                  jsonResponse['EmployeeID'],
                  jsonResponse['Password'],
                );

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (authProvider.auth.success == true) {
                  globals.appAuth = authProvider.auth;
                  globals.totalTask = 0;
                  globals.totalActivity = 0;

                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                  );
                } else {
                  if (authProvider.auth.message != null) {
                    AppSnackBar.danger(
                      context,
                      authProvider.auth.message,
                    );
                  }
                }
              }
            }
          }
        },
      );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
