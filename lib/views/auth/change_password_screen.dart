import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/validate.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/textfield.dart';
import 'package:ess_mobile/widgets/button.dart';
import 'package:ess_mobile/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _passwordController = TextEditingController(text: '');
  TextEditingController _passwordNewController =
      TextEditingController(text: '');
  TextEditingController _passwordConfirmController =
      TextEditingController(text: '');

  bool _disabled = false;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title:
            Text(AppLocalizations.of(context).translate('ChangePassword')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _buildForm(context),
      )
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
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppTextField(
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      onPressed: _toggle,
                      icon: _obscureText ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                    ),
                    labelText: AppLocalizations.of(context)
                        .translate('CurrentPassword'),
                    controller: _passwordController,
                    validator: (String? value) {
                      return Validate.requiredField(
                        value!,
                        'Current password is required.',
                      );
                    },
                    obscureText: _obscureText,
                  ),
                  SizedBox(height: 20),
                  AppTextField(
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      onPressed: _toggle,
                      icon: _obscureText ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                    ),
                    labelText: AppLocalizations.of(context)
                        .translate('NewPassword'),
                    controller: _passwordNewController,
                    validator: (String? value) {
                      return Validate.requiredField(
                        value!,
                        'New password is required.',
                      );
                    },
                    obscureText: _obscureText,
                  ),
                  SizedBox(height: 20),
                  AppTextField(
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      onPressed: _toggle,
                      icon: _obscureText ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                    ),
                    labelText: AppLocalizations.of(context)
                        .translate('ConfirmNewPassword'),
                    controller: _passwordConfirmController,
                    validator: (String? value) {
                      return Validate.requiredField(
                        value!,
                        'Confirm password is required.',
                      );
                    },
                    obscureText: _obscureText,
                  ),
                  SizedBox(height: 20),
                  (_disabled)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : AppButton(
                        label: AppLocalizations.of(context)
                            .translate('SaveChanges'),
                        onPressed: () async {
                          if (_passwordNewController.text !=
                              _passwordConfirmController.text) {
                            AppSnackBar.danger(context,
                                'Password confirmation does not match');
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();

                            setState(() {
                              _disabled = true;
                            });

                            Map<String, dynamic> body = {
                              'EmployeeID': globals.appAuth.user!.id.toString(),
                              'Password': _passwordController.text,
                              'NewPassword':
                                  _passwordNewController.text,
                            };

                            ApiResponse<dynamic> result =
                                await authProvider.changePassword(body);

                            if (result.status == ApiStatus.ERROR) {
                              AppSnackBar.danger(context, 'Error: '+ result.message);
                            }

                            if (result.status == ApiStatus.COMPLETED) {
                              if (result.data.statusCode == 200) {
                                AppSnackBar.success(
                                    context, result.data.message);
                                context.read<AuthProvider>().signOut();

                                Navigator.pop(context);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.login,
                                  ModalRoute.withName(Routes.login),
                                );
                              } else {
                                AppSnackBar.danger(
                                    context, result.data.message);
                              }
                            }

                            Future.delayed(Duration.zero, () async {
                              setState(() {
                                _disabled = false;
                              });
                            });
                          }
                        },
                      ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    _passwordNewController.dispose();
    _passwordConfirmController.dispose();
    
    super.dispose();
  }
}
