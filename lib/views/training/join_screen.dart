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
import 'package:ess_mobile/services/training_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/training_model.dart';

class TrainingJoinScreen extends StatefulWidget {
  @override
  _TrainingJoinScreenState createState() => _TrainingJoinScreenState();
}

class _TrainingJoinScreenState extends State<TrainingJoinScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TrainingService _trainingService = TrainingService();

  Future<TrainingModel?>? _formValue;
  List<TrainingReferenceModel> _reference = [];
  bool _disabled = true;
  bool _readonly = true;
  List<String> _checked = [];

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

    _trainingService.trainingReference(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _reference = [];

          v.data.data.forEach((i) {
            _reference.add(TrainingReferenceModel.fromJson(i.toJson()));
          });
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _disabled = false;
            _readonly = false;
            _formValue = _arguments();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('SignUpTraining')),
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
      child: FutureBuilder<TrainingModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};
          List<Widget> _children = <Widget>[];

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['schedule']['start'] != null) {
              DateTime _scheduleStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['schedule']['start'], false)
                  .toLocal();

              _init['scheduleStartPicker'] = _scheduleStart;
            } else {
              _init['scheduleStartPicker'] = DateTime.now();
            }

            if (_init['schedule']['finish'] != null) {
              DateTime _scheduleFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['schedule']['finish'], false)
                  .toLocal();

              _init['scheduleFinishPicker'] = _scheduleFinish;
            } else {
              _init['scheduleFinishPicker'] = DateTime.now();
            }

            if (_init['registrationDeadline'] != null) {
              DateTime _registrationDeadline = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['registrationDeadline'], false)
                  .toLocal();

              _init['registrationDeadlinePicker'] = _registrationDeadline;
            } else {
              _init['registrationDeadlinePicker'] = DateTime.now();
            }

            Map<String, List<TrainingReferenceModel>> _dataMap = {};

            _reference.sort((a, b) {
              return a.type.toString().compareTo(b.type.toString());
            });

            _reference.forEach((v) {
              if (!_dataMap.containsKey(v.typeDescription)) {
                _dataMap[v.typeDescription!] = <TrainingReferenceModel>[];
              }

              _dataMap[v.typeDescription]!.add(v);
            });

            bool _expanded = true;

            _dataMap.forEach((k, v) {
              _children.add(
                _buildExpansionTile(context, k, v, _expanded),
              );
              _expanded = false;
            });
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
                        AppLocalizations.of(context).translate('Name'),
                        false,
                        FormBuilderTextField(
                          name: 'name',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Name'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('ScheduleStart'),
                        false,
                        FormBuilderDateTimePicker(
                          name: 'scheduleStartPicker',
                          inputType: InputType.both,
                          format: DateFormat('EEEE, dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('ScheduleStart'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('ScheduleEnd'),
                        false,
                        FormBuilderDateTimePicker(
                          name: 'scheduleFinishPicker',
                          inputType: InputType.both,
                          format: DateFormat('EEEE, dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('ScheduleEnd'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context)
                            .translate('RegistrationDeadline'),
                        false,
                        FormBuilderDateTimePicker(
                          name: 'registrationDeadlinePicker',
                          inputType: InputType.both,
                          format: DateFormat('EEEE, dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('RegistrationDeadline'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Location'),
                        false,
                        FormBuilderTextField(
                          name: 'location',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Location'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context)
                            .translate('Terms&Condition'),
                        false,
                        FormBuilderTextField(
                          name: 'note',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Terms&Condition'),
                              ),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('Reference'),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme!
                                .secondary
                                .withOpacity(0.9),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: _children,
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

  Widget _buildExpansionTile(
    BuildContext context,
    String title,
    List<TrainingReferenceModel> items,
    bool expanded,
  ) {
    List<Widget> _children = <Widget>[];

    if (items.length > 0) {
      items.asMap().forEach((i, v) {
        v.description ??= '';

        String _validity = 'N/A';

        if (v.typeDescription == 'Certificate') {
          DateTime _validityStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
              .parse(v.validity!.start!, false)
              .toLocal();
          DateTime _validityFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
              .parse(v.validity!.finish!, false)
              .toLocal();
          _validity = DateFormat('dd MMM yyyy').format(_validityStart) +
              ' - ' +
              DateFormat('dd MMM yyyy').format(_validityFinish);
        }

        if (v.typeDescription == 'Document') {
          DateTime _createdDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
              .parse(v.createdDate!, false)
              .toLocal();
          _validity = DateFormat('dd MMM yyyy').format(_createdDate);
        }

        _children.add(
          ClipRRect(
            child: Container(
              color: (i % 2 == 0)
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.4),
              child: CheckboxListTile(
                title: Text(v.description.toString()),
                subtitle: Text(_validity.replaceAll('00:00', '')),
                value: _checked.contains(v.axid.toString()),
                onChanged: (bool? value) {
                  if (value == true) {
                    setState(() {
                      _checked.add(v.axid.toString());
                    });
                  } else {
                    setState(() {
                      _checked.remove(v.axid.toString());
                    });
                  }
                },
              ),
            ),
          ),
        );
      });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        color: Colors.blueGrey.withOpacity(0.1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.double_arrow,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            'Type: $title',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          initiallyExpanded: expanded,
          children: _children,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<TrainingModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'readonly') {
          _readonly = v ??= true;
        }
      });

      return TrainingModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    TrainingModel _data = TrainingModel();

    _formValue?.then((val) async {
      if (val != null) {
        _data = val;
      }

      _data.id ??= '';
      _data.lastUpdate ??= '0001-01-01T00:00:00';
      _data.createdDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;

      if (_data.schedule == null) {
        _data.schedule = DateTimeModel();
      }

      _data.schedule!.trueMonthly ??= 0;
      _data.schedule!.month ??= 0;
      _data.schedule!.days ??= 0;
      _data.schedule!.hours ??= 0;
      _data.schedule!.seconds ??= 0;
      _data.schedule!.start = value['scheduleStartPicker']
          //.subtract(Duration(hours: 7))
          .toIso8601String();
      _data.schedule!.finish = value['scheduleFinishPicker']
          //.subtract(Duration(hours: 7))
          .toIso8601String();

      if (value['scheduleFinishPicker']
              .difference(value['scheduleStartPicker'])
              .inHours <
          1) {
        AppSnackBar.danger(
            context, 'Schedule End should be greater than Schedule Start');
        return;
      }

      setState(() {
        _disabled = true;
      });

      List<Map<String, dynamic>> _ref = [];

      _reference.forEach((v) {
        if (_checked.contains(v.axid.toString())) {
          _ref.add(v.toJson());
        }
      });

      Map<String, dynamic> _join = _data.toJson();
      _join['registrationDate'] = DateTime.now().toLocal().toIso8601String();
      _join['references'] = _ref;

      ApiResponse<dynamic> upload =
          await _trainingService.trainingRegister(_join);

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
