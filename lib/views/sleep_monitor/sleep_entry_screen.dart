import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/sleep_monitor_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/sleep_monitor_model.dart';

class SleepEntryScreen extends StatefulWidget {
  @override
  _SleepEntryScreenState createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final SleepMonitorService _sleepMonitorService = SleepMonitorService();

  Future<SleepMonitorModel?>? _formValue;
  bool _disabled = true;
  bool _readonly = true;

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

    Future.delayed(Duration.zero, () async {
      setState(() {
        _disabled = false;
        _readonly = false;
        _formValue = _arguments();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('SleepMonitor')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      ),
      navigationBar: (_readonly)
          ? null
          : BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.cancel),
                  label: 'Cancel',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.save_sharp),
                  label: 'Save',
                ),
              ],
              currentIndex: 1,
              selectedItemColor: (_disabled)
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).buttonTheme.colorScheme?.primary,
              onTap: (_disabled)
                  ? null
                  : (int index) {
                      if (index == 0) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }

                      if (index == 1) {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          _update(_formKey.currentState!.value);
                        } else {
                          AppSnackBar.danger(
                            context,
                            'Please enter all required fields.',
                          );
                        }
                      }
                    },
            ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<SleepMonitorModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {
            'totalTimeAwakened': '0',
            'totalWakeUpHours': '0.0',
          };

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            _init['totalWakeUpHours'] = _init['totalWakeUpHours'].toString();
            _init['totalTimeAwakened'] = _init['totalTimeAwakened'].toString();

            if (_init['actualSleep']['start'] != null) {
              DateTime _sleepStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['actualSleep']['start'], false)
                  .toLocal();

              _init['sleepStartPicker'] = _sleepStart;
            } else {
              _init['sleepStartPicker'] = DateTime.now();
            }

            if (_init['actualSleep']['finish'] != null) {
              DateTime _sleepFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['actualSleep']['finish'], false)
                  .toLocal();

              _init['sleepFinishPicker'] = _sleepFinish;
            } else {
              _init['sleepFinishPicker'] = DateTime.now();
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  initialValue: _init,
                  skipDisabled: false,
                  enabled: !_readonly,
                  child: Column(
                    children: [
                      _formInputGroup(
                        AppLocalizations.of(context).translate('SleepingTime'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'sleepStartPicker',
                          inputType: InputType.both,
                          format: DateFormat('dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('SleepingTime'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('WakeUpTime'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'sleepFinishPicker',
                          inputType: InputType.both,
                          format: DateFormat('dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('WakeUpTime'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('NumberOfAwake'),
                        true,
                        FormBuilderTextField(
                          name: 'totalTimeAwakened',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('NumberOfAwake'),
                            hintText: '0',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.integer(context),
                          ]),
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (val) {},
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('TotalAwake'),
                        true,
                        FormBuilderTextField(
                          name: 'totalWakeUpHours',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('TotalAwake'),
                            hintText: '0.0',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.numeric(context),
                          ]),
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (val) {},
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                )
              : AppLoading();
        },
      ),
    );
  }

  Widget _formInputGroup(String label, bool asterisk, Widget formInput) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                color: Theme.of(context)
                    .buttonTheme
                    .colorScheme!
                    .secondary
                    .withOpacity(0.9),
              ),
            ),
            (asterisk)
                ? Text('*', style: TextStyle(color: Colors.red))
                : Text(''),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: (_readonly)
              ? Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: TextTheme(
                      subtitle1:
                          TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  ),
                  child: formInput,
                )
              : formInput,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<SleepMonitorModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'readonly') {
          _readonly = v ??= true;
        }
      });

      return SleepMonitorModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    SleepMonitorModel _data = SleepMonitorModel();

    _formValue?.then((val) async {
      if (val != null) {
        _data = val;
      }

      _data.id ??= '';
      _data.lastUpdate ??= '0001-01-01T00:00:00';
      _data.createdDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;
      _data.totalSleepHours ??= 0;
      _data.totalWakeUpHours = double.parse(value['totalWakeUpHours']);
      _data.totalTimeAwakened = int.parse(value['totalTimeAwakened']);

      if (_data.actualSleep == null) {
        _data.actualSleep = DateTimeModel();
      }

      _data.actualSleep!.trueMonthly ??= 0;
      _data.actualSleep!.month ??= 0;
      _data.actualSleep!.days ??= 0;
      _data.actualSleep!.hours ??= 0;
      _data.actualSleep!.seconds ??= 0;
      _data.actualSleep!.start = value['sleepStartPicker']
          .subtract(Duration(hours: 7))
          .toIso8601String();
      _data.actualSleep!.finish = value['sleepFinishPicker']
          .subtract(Duration(hours: 7))
          .toIso8601String();

      _data.totalSleepHours = value['sleepFinishPicker']
              .difference(value['sleepStartPicker'])
              .inHours -
          _data.totalWakeUpHours;

      if (value['sleepFinishPicker']
              .difference(value['sleepStartPicker'])
              .inHours <
          1) {
        AppSnackBar.danger(
            context, 'Wake Up Time should be greater than Sleeping Time');
        return;
      }

      setState(() {
        _disabled = true;
      });

      ApiResponse<dynamic> upload = await _sleepMonitorService.sleepmonitorSave(
        (_data.id == '') ? 'create' : 'update',
        _data.toJson(),
      );

      if (upload.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, upload.message);
      }

      if (upload.status == ApiStatus.COMPLETED) {
        if (upload.data.statusCode == 200) {
          AppSnackBar.success(context, upload.data.message.toString());
          Navigator.pop(context);
        }

        if (upload.data.statusCode == 400) {
          AppSnackBar.danger(context, upload.data.message.toString());
        }
      }

      Future.delayed(Duration.zero, () async {
        setState(() {
          _disabled = false;
        });
      });
    });
  }
}
