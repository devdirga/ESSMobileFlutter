import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/validate.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/widgets/logo.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/textfield.dart';
import 'package:ess_mobile/widgets/button.dart';
import 'package:ess_mobile/widgets/background.dart';
import 'package:ess_mobile/widgets/copyright.dart';
import 'package:ess_mobile/providers/auth_provider.dart';

class CreatePasswordScreen extends StatefulWidget {
  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _idController = TextEditingController(text: '');
  TextEditingController _passwordController = TextEditingController(text: '');
  TextEditingController _passwordConfirmController =
      TextEditingController(text: '');

  bool _disabled = false;

  @override
  void initState() {
    super.initState();
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
                  'RESET YOUR PASSWORD',
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
                        labelText: AppLocalizations.of(context)
                            .translate('NewPassword'),
                        controller: _passwordController,
                        validator: (String? value) {
                          return Validate.validatePassword(value.toString());
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      AppTextField(
                        prefixIcon: Icons.lock,
                        labelText: AppLocalizations.of(context)
                            .translate('ConfirmNewPassword'),
                        controller: _passwordConfirmController,
                        validator: (String? value) {
                          return Validate.validatePassword(value.toString());
                        },
                        obscureText: true,
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
                                if (_passwordController.text !=
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
                                    'EmployeeID': _idController.text,
                                    'NewPassword': _passwordController.text,
                                    'ConfirmPassword':
                                        _passwordConfirmController.text,
                                  };

                                  ApiResponse<dynamic> result =
                                      await authProvider.createPassword(body);

                                  if (result.status == ApiStatus.ERROR) {
                                    AppSnackBar.danger(context, result.message);
                                  }

                                  if (result.status == ApiStatus.COMPLETED) {
                                    if (result.data.statusCode == 200) {
                                      AppSnackBar.success(
                                          context, result.data.message);
                                      Navigator.of(context)
                                          .pushReplacementNamed(Routes.login);
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
                      SizedBox(height: 30),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context).translate('BackToLogin'),
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.login);
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

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    
    super.dispose();
  }
}
