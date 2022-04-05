import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/listsearch.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/time_management_model.dart';

class AbsenceDetail extends StatefulWidget {
  @override
  _AbsenceDetailState createState() => _AbsenceDetailState();
}

class _AbsenceDetailState extends State<AbsenceDetail> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TimeManagementService _timeManagementService = TimeManagementService();
  final MasterService _masterService = MasterService();

  Future<TimeAttendanceModel?>? _formValue;
  List<Map<String, dynamic>> _absenceCode = [];
  PlatformFile? _filePicker;
  bool _disabled = true;
  bool _readonly = true;
  String _trackingStatusDesc = 'InReview';
  DateTime? _actualLogedDate;

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

    _masterService.absenceCode().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _absenceCode = [];

          v.data.data.forEach((i) {
            _absenceCode.add(i.toJson());
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('Recommendation')),
            Text(AppLocalizations.of(context).translate('Absence')),
          ],
        ),
        toolbarHeight: 70,
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
      child: FutureBuilder<TimeAttendanceModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['AbsenceCodeDescription'] == null ||
                _init['AbsenceCodeDescription'] == '') {
              _absenceCode.forEach((v) {
                if (v['IdField'].toString() ==
                    _init['AbsenceCode'].toString()) {
                  _init['AbsenceCodeDescription'] = v['DescriptionField'];
                }
              });
            } else {
              bool _absenceExist = false;
              _absenceCode.forEach((v) {
                if (v['IdField'].toString() ==
                    _init['AbsenceCode'].toString()) {
                  _absenceExist = true;
                }
              });

              if (!_absenceExist) {
                if (_init['AbsenceCode'] != null &&
                    _init['AbsenceCodeDescription'] != null) {
                  _absenceCode.add({
                    'IdField': _init['AbsenceCode'],
                    'DescriptionField': _init['AbsenceCodeDescription']
                  });
                } else {
                  _init['AbsenceCode'] = null;
                  _init['AbsenceCodeDescription'] = null;
                }
              }
            }

            if (_init['AbsenceCode'] == '') {
              _init['AbsenceCode'] = null;
              _init['AbsenceCodeDescription'] = null;
            }

            if (_init['LoggedDate'] != null) {
              DateTime _loggedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['LoggedDate'], false)
                  .toLocal();

              _init['LoggedDatePicker'] = _loggedDate;
            } else {
              _init['LoggedDatePicker'] = DateTime.now();
            }

            if (_init['ActualLogedDate']['Start'] != null) {
              DateTime _actualLogedDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['ActualLogedDate']['Start'], false)
                  .toLocal();

              _init['ActualLogedDateStartPicker'] = _actualLogedDateStart;
            } else {
              _init['ActualLogedDateStartPicker'] = DateTime.now();
            }

            if (_init['ActualLogedDate']['Finish'] != null) {
              DateTime _actualLogedDateFinish =
                  DateFormat('yyyy-MM-ddTHH:mm:ss')
                      .parse(_init['ActualLogedDate']['Finish'], false)
                      .toLocal();

              _init['ActualLogedDateFinishPicker'] = _actualLogedDateFinish;
            } else {
              _init['ActualLogedDateFinishPicker'] = DateTime.now();
            }

            _init['FilePicker'] = '';
            _actualLogedDate = _init['ActualLogedDateStartPicker'];
            _init['TrackingStatusDescription'] = _trackingStatusDesc;
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
                        AppLocalizations.of(context).translate('Status'),
                        true,
                        FormBuilderTextField(
                          name: 'TrackingStatusDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Reason'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('AbsenceCode'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'AbsenceCodeDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('AbsenceCode'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _absenceCode
                              .map((item) => DropdownMenuItem(
                                    value: item['DescriptionField'].toString(),
                                    child: Text(
                                        item['DescriptionField'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          onTap: () {
                            Navigator.pop(_formKey.currentContext!);
                            AppListSearch(context).show(
                              _absenceCode,
                              value: 'IdField',
                              label: 'DescriptionField',
                              select: (val) {
                                _formKey.currentState!
                                    .fields['AbsenceCodeDescription']!
                                    .didChange(
                                        val['DescriptionField'].toString());
                              },
                            );
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Date'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'LoggedDatePicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText:
                              //     AppLocalizations.of(context).translate('Date'),
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
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _formInputGroup(
                              AppLocalizations.of(context).translate('ClockIn'),
                              true,
                              FormBuilderDateTimePicker(
                                name: 'ActualLogedDateStartPicker',
                                inputType: InputType.time,
                                decoration: InputDecoration(
                                    // labelText: AppLocalizations.of(context)
                                    //     .translate('ClockIn'),
                                    ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context),
                                ]),
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                          Expanded(
                            child: _formInputGroup(
                              AppLocalizations.of(context)
                                  .translate('ClockOut'),
                              true,
                              FormBuilderDateTimePicker(
                                name: 'ActualLogedDateFinishPicker',
                                inputType: InputType.time,
                                decoration: InputDecoration(
                                    // labelText: AppLocalizations.of(context)
                                    //     .translate('ClockOut'),
                                    ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context),
                                ]),
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Reason'),
                        true,
                        FormBuilderTextField(
                          name: 'Reason',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Reason'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 10),
                      (!_readonly)
                          ? _formInputGroup(
                              AppLocalizations.of(context)
                                  .translate('DocumentVerification'),
                              true,
                              FormBuilderTextField(
                                name: 'FilePicker',
                                decoration: InputDecoration(
                                  // labelText: AppLocalizations.of(context)
                                  //     .translate('DocumentVerification'),
                                  suffixIcon: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.file_upload),
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate('Upload'),
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            withReadStream: true,
                                          );

                                          if (result != null) {
                                            _filePicker = result.files.single;
                                            _formKey.currentState!
                                                .fields['FilePicker']!
                                                .didChange(_filePicker!.name);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context),
                                ]),
                                onChanged: (val) {},
                                readOnly: true,
                              ),
                            )
                          : Container(),
                      (!_readonly) ? SizedBox(height: 10) : Container(),
                      (_readonly)
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.file_download,
                                      color: (_init['Accessible'])
                                          ? null
                                          : Theme.of(context).disabledColor,
                                    ),
                                    Text(
                                      AppLocalizations.of(context).translate(
                                          'DownloadDocumentVerification'),
                                      style: (_init['Accessible'])
                                          ? null
                                          : TextStyle(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  if (_init['Accessible']) {
                                    // globals.launchInBrowser(
                                    //   '${globals.apiUrl}/timemanagement/download/${_init['employeeID']}/${_init['axRequestID']}',
                                    // );
                                    print('${globals.apiUrl}/ess/timemanagement/MDownload/${_init['EmployeeID']}/${_init['AXRequestID']}/${_init['Filename']}');
                                    Navigator.pushNamed(
                                      context,
                                      Routes.downloader,
                                      arguments: {
                                        'name':
                                            'Document Verification (${_init['AbsenceCodeDescription']})',
                                        'link':
                                            '${globals.apiUrl}/ess/timemanagement/MDownload/${_init['EmployeeID']}/${_init['AXRequestID']}/${_init['Filename']}',
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),
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

  Future<TimeAttendanceModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if(k == 'Readonly') _readonly = v ?? true;
        if(k == 'TrackingStatusDescription') _trackingStatusDesc = v ?? 'InReview';
      });

      return TimeAttendanceModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    TimeAttendanceModel _data = TimeAttendanceModel();

    _formValue?.then((val) async {
      if (val != null) {
        _data = val;
      }

      _data.axid ??= -1;
      _data.axRequestID ??= null;
      _data.action ??= 0;
      _data.accessible ??= false;
      _data.status ??= 0;
      _data.statusDescription ??= 'InReview';
      _data.lastUpdate ??= '0001-01-01T00:00:00';
      _data.createdDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;
      _data.absenceCodeDescription = value['AbsenceCodeDescription'];
      _data.reason = value['Reason'].toString().trim();
      _data.loggedDate = value['LoggedDatePicker'].toLocal().toIso8601String();

      if (_data.actualLogedDate == null) {
        _data.actualLogedDate = DateTimeModel();
      }

      _data.actualLogedDate!.trueMonthly ??= 0;
      _data.actualLogedDate!.month ??= 0;
      _data.actualLogedDate!.days ??= 0;
      _data.actualLogedDate!.hours ??= 0;
      _data.actualLogedDate!.seconds ??= 0;

      String _start = value['ActualLogedDateStartPicker']
          .toLocal()
          .toIso8601String()
          .substring(10);
      String _finish = value['ActualLogedDateFinishPicker']
          .toLocal()
          .toIso8601String()
          .substring(10);

      DateTime _loggedDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
          .parse(_actualLogedDate.toString().substring(0, 10) + _start, false)
          .toLocal();
      DateTime _loggedDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
          .parse(_actualLogedDate.toString().substring(0, 10) + _finish, false)
          .toLocal();

      _data.actualLogedDate!.start =
          _loggedDateStart.toIso8601String();
      _data.actualLogedDate!.finish =
          _loggedDateFinish.toIso8601String();

      _absenceCode.forEach((v) {
        if (v['DescriptionField'].toString() ==
            _data.absenceCodeDescription.toString()) {
          _data.absenceCode = v['IdField'];
        }
      });

      if (_loggedDateFinish.difference(_loggedDateStart).inHours < 1) {
        AppSnackBar.danger(
            context, 'Clock Out should be greater than Clock In');
        return;
      }

      if (_filePicker != null) {
        setState(() {
          _disabled = true;
        });

        ApiResponse<dynamic> upload =
            await _timeManagementService.timeAttendanceSave(
          (_data.axid == -1) ? 'Create' : 'Update',
          _filePicker!,
          JsonEncoder().convert(_data.toJson()),
          _data.reason!,
        );

        if (upload.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, upload.message);
        }

        if (upload.status == ApiStatus.COMPLETED) {
          if (upload.data['StatusCode'] == 200) {
            AppSnackBar.success(context, upload.data['Message'].toString());
            Navigator.pop(context);
          }

          if (upload.data['StatusCode'] == 400) {
            AppSnackBar.danger(context, upload.data['Message'].toString());
          }
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _disabled = false;
            _filePicker = null;
            _formKey.currentState!.fields['FilePicker']!.didChange('');
          });
        });
      } else {
        AppAlert(context).attachment(
          title:
              AppLocalizations.of(context).translate('RecommendationAbsence'),
        );
      }
    });
  }
}
