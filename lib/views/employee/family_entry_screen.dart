import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/family_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/family_model.dart';

class FamilyEntryScreen extends StatefulWidget {
  @override
  _FamilyEntryScreenState createState() => _FamilyEntryScreenState();
}

class _FamilyEntryScreenState extends State<FamilyEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final FamilyService _familyService = FamilyService();
  final MasterService _masterService = MasterService();

  Future<FamilyModel?>? _formValue;
  List<String> _gender = [];
  List<String> _religion = [];
  List<Map<String, dynamic>> _familyRelationship = [];
  PlatformFile? _filePicker;
  bool _disabled = true;
  bool _readonly = true;
  bool _loading = false;

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

    _masterService.gender().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _gender = v.data.data;
        }
      }
    });

    _masterService.religion().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _religion = v.data.data;
        }
      }
    });

    _masterService.familyRelationship().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _familyRelationship = [];

          v.data.data.forEach((i) {
            _familyRelationship.add(i.toJson());
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
        title:
            Text(AppLocalizations.of(context).translate('FamilyInformation')),
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
      child: FutureBuilder<FamilyModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['GenderDescription'] == null ||
                _init['GenderDescription'] == '') {
              _gender.asMap().forEach((k, v) {
                if (k == _init['Gender']) {
                  _init['GenderDescription'] = v.toString();
                }
              });
            }

            if (_init['ReligionDescription'] == null ||
                _init['ReligionDescription'] == '') {
              _religion.asMap().forEach((k, v) {
                if (k == _init['Religion']) {
                  _init['ReligionDescription'] = v.toString();
                }
              });
            }

            if (_init['RelationshipDescription'] == null ||
                _init['RelationshipDescription'] == '') {
              _familyRelationship.forEach((v) {
                if (v['TypeID'].toString() ==
                    _init['Relationship'].toString()) {
                  _init['RelationshipDescription'] = v['Description'];
                }
              });
            } else {
              bool _relationExist = false;
              _familyRelationship.forEach((v) {
                if (v['TypeID'].toString() ==
                    _init['Relationship'].toString()) {
                  _relationExist = true;
                }
              });

              if (!_relationExist) {
                if (_init['Relationship'] != null &&
                    _init['RelationshipDescription'] != null) {
                  _familyRelationship.add({
                    'TypeID': _init['Relationship'],
                    'Description': _init['RelationshipDescription']
                  });
                } else {
                  _init['Relationship'] = null;
                  _init['RelationshipDescription'] = null;
                }
              }
            }

            if (_init['Birthdate'] != null) {
              DateTime _birthdate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Birthdate'], false)
                  .toLocal();

              _init['BirthdatePicker'] = _birthdate;
            } else {
              _init['BirthdatePicker'] = DateTime.now();
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
                        AppLocalizations.of(context).translate('FirstName'),
                        true,
                        FormBuilderTextField(
                          name: 'FirstName',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('FirstName'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('MiddleName'),
                        false,
                        FormBuilderTextField(
                          name: 'MiddleName',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('MiddleName'),
                              ),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('LastName'),
                        true,
                        FormBuilderTextField(
                          name: 'LastName',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('LastName'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Gender'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'GenderDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Gender'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _gender
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Relationship'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'RelationshipDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _familyRelationship
                              .map((item) => DropdownMenuItem(
                                    value: item['Description'].toString(),
                                    child: Text(item['Description'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Religion'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'ReligionDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Religion'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _religion
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('NIK'),
                        true,
                        FormBuilderTextField(
                          name: 'NIK',
                          decoration: InputDecoration(
                              // labelText:
                              //     AppLocalizations.of(context).translate('NIK'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          //enabled: (_init.isNotEmpty) ? false : true,
                          //style: (_init.isNotEmpty)
                              //? TextStyle(
                              //    color: Theme.of(context).disabledColor)
                              //: null,
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('BirthDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'BirthdatePicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('BirthDate'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('BirthPlace'),
                        true,
                        FormBuilderTextField(
                          name: 'Birthplace',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('BirthPlace'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
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
                                    //   '${globals.apiUrl}/employee/family/document/download/${_init['employeeID']}/${_init['axid']}',
                                    // );

                                    Navigator.pushNamed(
                                      context,
                                      Routes.downloader,
                                      arguments: {
                                        'name':
                                            'Document Verification (${_init['Name']})',
                                        'link':
                                            '${globals.apiUrl}/ess/employee/MDownloadFamilyDocument/${_init['EmployeeID']}/${_init['AXID']}/${_init['Filename']}',
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

  Future<FamilyModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'Readonly') {
          _readonly = v ??= true;
        }
      });

      return FamilyModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    FamilyModel _data = FamilyModel();

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
      _data.firstName = value['FirstName'].toString().trim();
      _data.middleName = (value['MiddleName']?.toString() == null)
          ? ''
          : value['MiddleName'].toString().trim();
      _data.lastName = value['LastName'].toString().trim();
      _data.name =
          _data.firstName! + ' ' + _data.middleName! + ' ' + _data.lastName!;
      _data.genderDescription = value['GenderDescription'];
      _data.religionDescription = value['ReligionDescription'];
      _data.relationshipDescription = value['RelationshipDescription'];
      _data.nik = value['NIK'];
      _data.birthdate =
          value['BirthdatePicker'].add(Duration(hours: 7)).toIso8601String();
      _data.birthplace = value['Birthplace'].toString().trim();

      _gender.asMap().forEach((k, v) {
        if (v.toString() == _data.genderDescription.toString()) {
          _data.gender = k;
        }
      });

      _religion.asMap().forEach((k, v) {
        if (v.toString() == _data.religionDescription.toString()) {
          _data.religion = k;
        }
      });

      _familyRelationship.forEach((v) {
        if (v['Description'].toString() ==
            _data.relationshipDescription.toString()) {
          _data.relationship = v['TypeID'];
        }
      });

      if (_filePicker != null) {
        AppAlert(context).save(
          title: AppLocalizations.of(context).translate('FamilyInformation'),
          yes: (String? val) async {
            _data.reason = val.toString().trim();

            setState(() {
              _loading = true;
              _disabled = true;
            });

            ApiResponse<dynamic> upload = await _familyService.familySave(
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
                _loading = false;
                _filePicker = null;
                _formKey.currentState!.fields['FilePicker']!.didChange('');
              });
            });
          },
        );
      } else {
        AppAlert(context).attachment(
          title: AppLocalizations.of(context).translate('FamilyInformation'),
        );
      }
    });
  }
}
