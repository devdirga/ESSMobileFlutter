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

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _idController = TextEditingController(text: '');
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _passwordController = TextEditingController(text: '');

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
                  'REGISTER FOR ESS',
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
                        prefixIcon: Icons.email,
                        labelText:
                            AppLocalizations.of(context).translate('Email'),
                        controller: _emailController,
                        validator: (String? value) {
                          return Validate.validateEmail(value.toString());
                        },
                      ),
                      SizedBox(height: 20),
                      AppTextField(
                        prefixIcon: Icons.lock,
                        labelText:
                            AppLocalizations.of(context).translate('Password'),
                        controller: _passwordController,
                        validator: (String? value) {
                          return Validate.validatePassword(value.toString());
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      authProvider.status == AppStatus.Registering
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : AppButton(
                              label: AppLocalizations.of(context)
                                  .translate('SignUp'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  ApiResponse<dynamic> result =
                                      await authProvider.register(
                                    _idController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                  );

                                  if (result.status == ApiStatus.ERROR) {
                                    AppSnackBar.danger(context, result.message);
                                  }

                                  if (result.status == ApiStatus.COMPLETED) {
                                    if (authProvider.auth.success == true) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        Routes.login,
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
                      SizedBox(height: 50),
                      Text(
                        AppLocalizations.of(context)
                            .translate('AlreadyHaveAccount'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context).translate('SignIn'),
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
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
