import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
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

class VerificationCodeScreen extends StatefulWidget {
  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _idController = TextEditingController(text: '');
  TextEditingController _codeController = TextEditingController(text: '');

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
                  'VERIFY YOUR IDENTITY',
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
                      Text('Open your email and find the verification code.'),
                      SizedBox(height: 20),
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
                        prefixIcon: Icons.verified,
                        labelText: AppLocalizations.of(context)
                            .translate('VerificationCode'),
                        controller: _codeController,
                        validator: (String? value) {
                          return Validate.requiredField(
                            value!,
                            'Verification Code is required.',
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      (_disabled)
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : AppButton(
                              label: AppLocalizations.of(context)
                                  .translate('Verify'),
                              onPressed: () async {
                                if (!globals.isNumeric(_codeController.text)) {
                                  AppSnackBar.danger(context,
                                      'Invalid number format for verification code');
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    _disabled = true;
                                  });

                                  Map<String, dynamic> body = {
                                    'EmployeeID': _idController.text,
                                    'VerificationCode': _codeController.text,
                                  };

                                  ApiResponse<dynamic> result =
                                      await authProvider.verificationCode(body);

                                  if (result.status == ApiStatus.ERROR) {
                                    AppSnackBar.danger(context, result.message);
                                  }

                                  if (result.status == ApiStatus.COMPLETED) {
                                    if (result.data.statusCode == 200) {
                                      AppSnackBar.success(
                                          context, result.data.message);
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.createPassword);
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
                          AppLocalizations.of(context)
                              .translate('SendCodeAgain'),
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.forgotPassword);
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
    _codeController.dispose();

    super.dispose();
  }
}
