import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/listsearch.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/leave_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/leave_model.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final LeaveService _leaveService = LeaveService();

  Future<LeaveModel?>? _formValue;
  List<Map<String, dynamic>> _subtitution = [];
  List<Map<String, dynamic>> _leaveType = [];
  PlatformFile? _filePicker;
  bool _disabled = true;
  bool _readonly = true;
  bool _loading = false;
  
  String _effectiveDate = '';
  int _currentRemainder = 0;
  int _waitingApproval = 0;
  int _leaveApplied = 0;

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

    _leaveService.subtitution(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _subtitution = [];

          v.data.data.forEach((i) {
            _subtitution.add(i.toJson());
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

    _leaveService.leaveType(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          int _periodStart = int.parse(globals.today.year.toString() +
              globals.today.month.toString().padLeft(2, '0') +
              globals.today.day.toString().padLeft(2, '0'));
          //int _periodFinish = int.parse(globals.today.year.toString() + '1231');

          _leaveType = [];

          v.data.data.forEach((i) {
            int _periodEffective = int.parse(i.effectiveDateTo
                .toString()
                .substring(0, 10)
                .replaceAll('-', ''));

            if (i.isClosed == false) {
              if (_periodEffective >= _periodStart) {
                _leaveType.add(i.toJson());
              }
            }
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
        title: Text(AppLocalizations.of(context).translate('LeaveRequest')),
      ),
      main: LoadingOverlay(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _container(context),
        ),
        isLoading: _loading,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
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
      child: FutureBuilder<LeaveModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['SubtituteEmployeeName'] == null ||
                _init['SubtituteEmployeeName'] == '') {
              _subtitution.forEach((v) {
                if (v['EmployeeID'].toString() ==
                    _init['SubtituteEmployeeID'].toString()) {
                  _init['SubtituteEmployeeName'] = v['Description'];
                }
              });
            } else {
              bool _subtitutionExist = false;
              _subtitution.forEach((v) {
                if (v['EmployeeID'].toString() ==
                    _init['SubtituteEmployeeID'].toString()) {
                  _subtitutionExist = true;
                }
              });

              if (!_subtitutionExist) {
                if (_init['SubtituteEmployeeID'] != null &&
                    _init['SubtituteEmployeeName'] != null) {
                  _subtitution.add({
                    'EmployeeID': _init['SubtituteEmployeeID'],
                    'EmployeeName': _init['SubtituteEmployeeName']
                  });
                } else {
                  _init['SubtituteEmployeeID'] = null;
                  _init['SubtituteEmployeeName'] = null;
                }
              }
            }

            if (_init['TypeDescription'] == null ||
                _init['TypeDescription'] == '') {
              _leaveType.forEach((v) {
                if (v['TypeId'].toString() == _init['Type'].toString()) {
                  _init['TypeDescription'] = v['Description'];
                }
              });
            } else {
              bool _typeExist = false;
              _leaveType.forEach((v) {
                if (v['TypeId'].toString() == _init['Type'].toString()) {
                  _typeExist = true;
                }
              });

              if (!_typeExist) {
                if (_init['Type'] != null && _init['TypeDescription'] != null) {
                  _leaveType.add({
                    'TypeId': _init['Type'],
                    'Description': _init['TypeDescription']
                  });
                } else {
                  _init['Type'] = null;
                  _init['TypeDescription'] = null;
                }
              }
            }

            if (_init['Schedule']['Start'] != null) {
              DateTime _scheduleStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Schedule']['Start'], false)
                  .toLocal();

              _init['ScheduleStartPicker'] = _scheduleStart;
            } else {
              _init['ScheduleStartPicker'] = DateTime.now();
            }

            if (_init['Schedule']['Finish'] != null) {
              DateTime _scheduleFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Schedule']['Finish'], false)
                  .toLocal();

              _init['ScheduleFinishPicker'] = _scheduleFinish;
            } else {
              _init['ScheduleFinishPicker'] = DateTime.now();
            }

            _init['FilePicker'] = '';
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
                        AppLocalizations.of(context)
                            .translate('SubtituteEmployee'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'SubtituteEmployeeName',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('SubtituteEmployee'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _subtitution
                              .map((item) => DropdownMenuItem(
                                    value: item['EmployeeName'].toString(),
                                    child:
                                        Text(item['EmployeeName'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          onTap: () {
                            Navigator.pop(_formKey.currentContext!);
                            AppListSearch(context).show(
                              _subtitution,
                              value: 'EmployeeID',
                              label: 'EmployeeName',
                              select: (val) {
                                _formKey.currentState!
                                    .fields['SubtituteEmployeeName']!
                                    .didChange(val['EmployeeName'].toString());
                              },
                            );
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('TypeLeave'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'Type',
                          decoration: InputDecoration(
                            helperText: _effectiveDate,
                            // labelText: AppLocalizations.of(context)
                            //     .translate('TypeLeave'),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _leaveType
                              .map((item) => DropdownMenuItem(
                                    value: item['TypeId'].toString(),
                                    child: Text(item['Description'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            String _valid = '';
                            int _remainder = 0;

                            _leaveType.forEach((v) {
                              if (v['TypeId'].toString() == val.toString()) {
                                DateTime _from =
                                    DateFormat('yyyy-MM-ddTHH:mm:ss')
                                        .parse(v['EffectiveDateFrom'], false)
                                        .toLocal();
                                DateTime _to = DateFormat('yyyy-MM-ddTHH:mm:ss')
                                    .parse(v['EffectiveDateTo'], false)
                                    .toLocal();

                                _valid =
                                    'Valid between ${DateFormat('dd MMM yyyy').format(_from)} until ${DateFormat('dd MMM yyyy').format(_to)}';
                                _remainder = v['Remainder'];
                              }
                            });

                            setState(() {
                              _effectiveDate = _valid;
                              _currentRemainder = _remainder;
                            });
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('StartDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'ScheduleStartPicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('StartDate'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {
                            var _start = _formKey.currentState
                                ?.fields['ScheduleStartPicker']?.value;
                            var _finish = _formKey.currentState
                                ?.fields['ScheduleFinishPicker']?.value;

                            if (_start != null && _finish != null) {
                              _checkLeaveExists(_start, _finish);

                              setState(() {
                                _waitingApproval =
                                    _finish.difference(_start).inDays;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('EndDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'ScheduleFinishPicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('EndDate'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {
                            var _start = _formKey.currentState
                                ?.fields['ScheduleStartPicker']?.value;
                            var _finish = _formKey.currentState
                                ?.fields['ScheduleFinishPicker']?.value;

                            if (_start != null && _finish != null) {
                              _checkLeaveExists(_start, _finish);

                              setState(() {
                                _waitingApproval =
                                    _finish.difference(_start).inDays;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Reason'),
                        true,
                        FormBuilderTextField(
                          name: 'Description',
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
                                  .translate('AdditionalDocument'),
                              false,
                              FormBuilderTextField(
                                name: 'FilePicker',
                                decoration: InputDecoration(
                                  // labelText: AppLocalizations.of(context)
                                  //     .translate('AdditionalDocument'),
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
                                onChanged: (val) {},
                                readOnly: true,
                              ),
                            )
                          : Container(),
                      (!_readonly) ? SizedBox(height: 10) : Container(),
                      (!_readonly)
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Current Remainder: $_currentRemainder',
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Waiting For Approval: $_waitingApproval',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
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
                                          'DownloadAdditionalDocument'),
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
                                    //   '${globals.apiUrl}/leave/download/${_init['employeeID']}/${_init['axRequestID']}',
                                    // );

                                    Navigator.pushNamed(
                                      context,
                                      Routes.downloader,
                                      arguments: {
                                        'name':
                                            'Additional Document (${_init['TypeDescription']})',
                                        'link':
                                            '${globals.apiUrl}/ess/leave/MDownload/${_init['EmployeeID']}/${_init['AXRequestID']}',
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

  Future<LeaveModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'readonly') {
          _readonly = v ??= true;
        }
      });

      return LeaveModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    LeaveModel _data = LeaveModel();

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
      _data.subtituteEmployeeName = value['SubtituteEmployeeName'];
      _data.type = value['Type'];
      _data.description = value['Description'].toString().trim();

      if (_data.schedule == null) {
        _data.schedule = DateTimeModel();
      }

      _data.schedule!.trueMonthly ??= 0;
      _data.schedule!.month ??= 0;
      _data.schedule!.days ??= 0;
      _data.schedule!.hours ??= 0;
      _data.schedule!.seconds ??= 0;
      _data.schedule!.start = value['ScheduleStartPicker']
          .subtract(Duration(hours: 7))
          .toIso8601String();
      _data.schedule!.finish = value['ScheduleFinishPicker']
          .subtract(Duration(hours: 7))
          .toIso8601String();
      _data.pendingRequest = value['ScheduleFinishPicker']
          .difference(value['ScheduleStartPicker'])
          .inDays;

      if (value['ScheduleFinishPicker']
              .difference(value['ScheduleStartPicker'])
              .inHours <
          0) {
        AppSnackBar.danger(
            context, 'End date should be greater than Start date');
        return;
      }

      if (_waitingApproval > _currentRemainder) {
        AppSnackBar.danger(context, 'Leave could not be more than remainder');
        return;
      }

      if (_leaveApplied > 0) {
        AppSnackBar.danger(context,
            'You have requested leave on this date, please request another date');
        return;
      }

      _subtitution.forEach((v) {
        if (v['EmployeeName'].toString() ==
            _data.subtituteEmployeeName.toString()) {
          _data.subtituteEmployeeID = v['EmployeeID'];
        }
      });

      _leaveType.forEach((v) {
        if (v['TypeId'].toString() == _data.type.toString()) {
          _data.typeDescription = v['Description'];
        }
      });

      setState(() {
        _loading = true;
        _disabled = true;
      });

      ApiResponse<dynamic> upload = await _leaveService.leaveRequest(
        (_data.axid == -1) ? 'create' : 'update',
        _filePicker,
        JsonEncoder().convert(_data.toJson()),
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
          _loading = false;
          _disabled = false;
        });
      });
    });
  }

  void _checkLeaveExists(DateTime start, DateTime finish) {
    Map<String, dynamic> getValue = {
      'Start': start.subtract(Duration(hours: 7)).toIso8601String(),
      'Finish': finish.subtract(Duration(hours: 7)).toIso8601String(),
      // 'finish': finish
      //     .add(Duration(hours: 23, minutes: 59))
      //     .subtract(Duration(hours: 7))
      //     .toIso8601String(),
    };

    _leaveService
        .calendar(globals.getFilterRequest(params: getValue, dateRange: false))
        .then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data != null) {
          if (v.data.data.leaves != null) {
            if (v.data.data.leaves.length > 0) {
              setState(() {
                _leaveApplied = v.data.data.leaves.length;
              });
            }
          }
        }
      }
    });
  }
}
