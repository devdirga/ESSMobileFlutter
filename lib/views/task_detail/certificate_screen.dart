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
import 'package:ess_mobile/services/certificate_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/certificate_model.dart';

class CertificateDetail extends StatefulWidget {
  @override
  _CertificateDetailState createState() => _CertificateDetailState();
}

class _CertificateDetailState extends State<CertificateDetail> {
  final _formKey = GlobalKey<FormBuilderState>();
  final CertificateService _certificateService = CertificateService();
  final MasterService _masterService = MasterService();

  Future<CertificateModel?>? _formValue;
  List<Map<String, dynamic>> _certificateType = [];
  PlatformFile? _filePicker;
  bool _disabled = true;
  bool _readonly = true;
  String _trackingStatusDesc = 'InReview';
  String _requestRenewal = '';

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

    _masterService.certificateType().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _certificateType = [];

          v.data.data.forEach((i) {
            _certificateType.add(i.toJson());
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
        title: Text(AppLocalizations.of(context).translate('Certificate')),
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
      child: FutureBuilder<CertificateModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {
            'Note': '',
            'ReqRenew': false,
          };

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['TypeDescription'] == null ||
                _init['TypeDescription'] == '') {
              _certificateType.forEach((v) {
                if (v['TypeID'].toString() == _init['TypeID'].toString()) {
                  _init['TypeDescription'] = v['Description'];
                }
              });
            } else {
              bool _certificateExist = false;
              _certificateType.forEach((v) {
                if (v['TypeID'].toString() == _init['TypeID'].toString()) {
                  _certificateExist = true;
                }
              });

              if (!_certificateExist) {
                _init['TypeID'] = null;
                _init['TypeDescription'] = null;
              }
            }

            if (_init['Validity']['Start'] != null) {
              DateTime _validityStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Validity']['Start'], false)
                  .toLocal();

              _init['ValidityStartPicker'] = _validityStart;
            } else {
              _init['ValidityStartPicker'] = DateTime.now();
            }

            if (_init['Validity']['Finish'] != null) {
              DateTime _validityFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Validity']['Finish'], false)
                  .toLocal();

              _init['ValidityFinishPicker'] = _validityFinish;
            } else {
              _init['ValidityFinishPicker'] = DateTime.now();
            }

            _init['FilePicker'] = '';
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
                        AppLocalizations.of(context).translate('Type'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'TypeDescription',
                          decoration: InputDecoration(
                            helperText: _requestRenewal,
                            // labelText:
                            //     AppLocalizations.of(context).translate('Type'),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _certificateType
                              .map((item) => DropdownMenuItem(
                                    value: item['Description'].toString(),
                                    child: Text(item['Description'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            bool _reqRenew = false;

                            _certificateType.forEach((v) {
                              if (v['Description'].toString() ==
                                  val.toString()) {
                                _reqRenew = v['ReqRenew'];
                              }
                            });

                            _formKey.currentState!.fields['ReqRenew']!
                                .didChange(_reqRenew);

                            setState(() {
                              _requestRenewal = 'Request Renewal : ' +
                                  (_reqRenew ? 'Yes' : 'No');
                            });
                          },
                          onTap: () {
                            Navigator.pop(_formKey.currentContext!);
                            AppListSearch(context).show(
                              _certificateType,
                              value: 'TypeID',
                              label: 'Description',
                              select: (val) {
                                _formKey
                                    .currentState!.fields['TypeDescription']!
                                    .didChange(val['Description'].toString());
                              },
                            );
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('IssuingDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'ValidityStartPicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('IssuingDate'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context)
                            .translate('ExpirationDate'),
                        false,
                        FormBuilderDateTimePicker(
                          name: 'ValidityFinishPicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('ExpirationDate'),
                              ),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(context),
                          // ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Note'),
                        false,
                        FormBuilderTextField(
                          name: 'Note',
                          decoration: InputDecoration(
                              // labelText:
                              //     AppLocalizations.of(context).translate('Note'),
                              ),
                          onChanged: (val) {},
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 10),
                      (!_readonly)
                          ? _formInputGroup(
                              AppLocalizations.of(context)
                                  .translate('CertificateFile'),
                              true,
                              FormBuilderTextField(
                                name: 'FilePicker',
                                decoration: InputDecoration(
                                  // labelText: AppLocalizations.of(context)
                                  //     .translate('CertificateFile'),
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
                      Visibility(
                        visible: false,
                        maintainState: true,
                        child: FormBuilderCheckbox(
                          name: 'ReqRenew',
                          title: Text(
                            AppLocalizations.of(context)
                                .translate('RequestRenewal'),
                          ),
                          onChanged: (val) {
                            /**/
                          },
                        ),
                      ),
                      Visibility(
                        visible: false,
                        maintainState: true,
                        child: SizedBox(height: 10),
                      ),
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
                                      AppLocalizations.of(context)
                                          .translate('DownloadCertificateFile'),
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
                                    //   '${globals.apiUrl}/employee/certificate/download/${_init['employeeID']}/${_init['axid']}',
                                    // );

                                    Navigator.pushNamed(
                                      context,
                                      Routes.downloader,
                                      arguments: {
                                        'name':
                                            'Certificate File (${_init['TypeDescription']})',
                                        'link':
                                            '${globals.apiUrl}/ess/employee/MDownloadCertificate/${_init['EmployeeID']}/${_init['AXID']}/${_init['Filename']}',
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

  Future<CertificateModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if(k == 'Readonly') _readonly = v ?? true;
        if(k == 'TrackingStatusDescription') _trackingStatusDesc = v ?? 'InReview';
      });

      return CertificateModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    CertificateModel _data = CertificateModel();

    _formValue?.then((val) {
      if (val != null) {
        _data = val;
      }

      _data.axid ??= -1;
      _data.axRequestID ??= null;
      _data.action ??= 0;
      _data.purpose ??= 0;
      _data.accessible ??= false;
      _data.status ??= 0;
      _data.statusDescription ??= 'InReview';
      _data.lastUpdate ??= '0001-01-01T00:00:00';
      _data.createdDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;
      _data.typeDescription = value['TypeDescription'];
      _data.note = value['Note'].toString().trim();
      _data.reqRenew = value['ReqRenew'];

      if (_data.validity == null) {
        _data.validity = DateTimeModel();
      }

      _data.validity!.trueMonthly ??= 0;
      _data.validity!.month ??= 0;
      _data.validity!.days ??= 0;
      _data.validity!.hours ??= 0;
      _data.validity!.seconds ??= 0;
      _data.validity!.start = value['ValidityStartPicker']
          .subtract(Duration(hours: 7))
          .toIso8601String();
      _data.validity!.finish = (value['ValidityFinishPicker'] == null)
          ? _data.validity!.start
          : value['ValidityFinishPicker']
              .subtract(Duration(hours: 7))
              .toIso8601String();

      _certificateType.forEach((v) {
        if (v['Description'].toString() == _data.typeDescription.toString()) {
          _data.typeID = v['TypeID'];
        }
      });

      if (value['ValidityFinishPicker']
              .difference(value['ValidityStartPicker'])
              .inHours <
          1) {
        AppSnackBar.danger(
            context, 'Expiration Date should be greater than Issuing Date');
        return;
      }

      if (_filePicker != null) {
        AppAlert(context).save(
          title: AppLocalizations.of(context).translate('Certificate'),
          yes: (String? val) async {
            _data.reason = val.toString().trim();

            setState(() {
              _disabled = true;
            });

            ApiResponse<dynamic> upload =
                await _certificateService.certificateSave(
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
          },
        );
      } else {
        AppAlert(context).attachment(
          title: AppLocalizations.of(context).translate('Certificate'),
        );
      }
    });
  }
}
