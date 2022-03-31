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
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/resume_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/resume_model.dart';
import 'package:ess_mobile/models/bank_account_model.dart';
import 'package:ess_mobile/models/tax_model.dart';
import 'package:ess_mobile/models/identification_model.dart';
import 'package:ess_mobile/models/electronic_address_model.dart';

class ResumeDetail extends StatefulWidget {
  @override
  _ResumeDetailState createState() => _ResumeDetailState();
}

class _ResumeDetailState extends State<ResumeDetail> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ResumeService _resumeService = ResumeService();
  final MasterService _masterService = MasterService();

  Future<EmployeeModel?>? _formValue;
  List<String> _gender = [];
  List<String> _religion = [];
  List<String> _maritalStatus = [];
  List<Map<String, dynamic>> _city = [];
  List<Map<String, dynamic>> _familyRelationship = [];
  List<Map<String, dynamic>> _identificationType = [];
  List<Map<String, dynamic>> _electronicAddressType = [];
  List<Map<String, dynamic>> _bankAccounts = [];
  List<Map<String, dynamic>> _identifications = [];
  List<Map<String, dynamic>> _electronicAddresses = [];
  List<Map<String, dynamic>> _taxes = [];
  AddressModel _address = AddressModel();
  bool _readonly = true;
  String _trackingStatusDesc = 'InReview';
  Map<String, bool> _change = {};
  Map<String, int> _upload = {};

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

    _masterService.maritalStatus().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _maritalStatus = v.data.data;
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
      }
    });

    _masterService.identificationType().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _identificationType = [];

          v.data.data.forEach((i) {
            _identificationType.add(i.toJson());
          });

          _identificationType.sort((a, b) {
            return a['Type'].compareTo(b['Type']);
          });
        }
      }
    });

    _masterService.electronicAddressType().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _electronicAddressType = [];

          v.data.data.forEach((i) {
            if (i.type != '0') {
              _electronicAddressType.add(i.toJson());
            }
          });

          _electronicAddressType.sort((a, b) {
            return a['Type'].compareTo(b['Type']);
          });
        }
      }
    });

    _masterService.city().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          Map<String, int> _tmp = {};
          _city = [];

          v.data.data.forEach((i) {
            if (!_tmp.containsKey(i.name)) {
              _tmp[i.name] = 1;
              _city.add(i.toJson());
            }
          });
        }

        _city.add({'Id': null, 'Name': ''});

        _resumeService
            .bankAccounts(globals.getFilterRequest(params: globals.params))
            .then((v) {
          if (v.status == ApiStatus.COMPLETED) {
            if (v.data.data.length > 0) {
              _bankAccounts = [];

              v.data.data.forEach((i) {
                _bankAccounts.add(i.toJson());
              });

              _bankAccounts.sort((a, b) {
                return a['AXID'].compareTo(b['AXID']);
              });
            }

            _resumeService
                .identifications(
                    globals.getFilterRequest(params: globals.params))
                .then((v) {
              if (v.status == ApiStatus.COMPLETED) {
                if (v.data.data.length > 0) {
                  _identifications = [];

                  v.data.data.forEach((i) {
                    if(i.type != 'NPWP'){
                      _identifications.add(i.toJson());
                    }
                  });
                }

                _resumeService
                    .electronicAddresses(
                        globals.getFilterRequest(params: globals.params))
                    .then((v) {
                  if (v.status == ApiStatus.COMPLETED) {
                    if (v.data.data.length > 0) {
                      _electronicAddresses = [];

                      v.data.data.forEach((i) {
                        _electronicAddresses.add(i.toJson());
                      });
                    }

                    _resumeService
                        .taxes(globals.getFilterRequest(params: globals.params))
                        .then((v) {
                      if (v.status == ApiStatus.COMPLETED) {
                        if (v.data.data.length > 0) {
                          _taxes = [];

                          v.data.data.forEach((i) {
                            _taxes.add(i.toJson());
                          });
                        }

                        _resumeService
                            .address(globals.getFilterRequest(
                                params: globals.params))
                            .then((v) {
                          if (v.status == ApiStatus.COMPLETED) {
                            if (v.data.data != null) {
                              _address = v.data.data;
                            }

                            Future.delayed(Duration.zero, () async {
                              setState(() {
                                _readonly = false;
                                _formValue = _arguments();
                              });
                            });
                          }
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('EmployeeProfile')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<EmployeeModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['Birthdate'] != null) {
              DateTime _birthdate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['Birthdate'], false)
                  .toLocal();

              _init['BirthdatePicker'] = _birthdate;
            } else {
              _init['BirthdatePicker'] = DateTime.now();
            }

            if (_address.street != null) {
              if(_init['Address'] != null) {
                _init['Address']['Street'] = _address.street.toString();
                _init['Address_street'] = _init['Address']['Street'] ?? '';
              }
            }

            if (_address.city != null) {
              if(_init['Address'] != null) {
                _init['Address']['City'] = _address.city.toString();
              } 
            }

            if (_address.axid != null) {
              if(_init['Address'] != null) {
                _init['Address']['AXID'] = _address.axid.toString();
                _init['Address_city'] = _init['Address']['City'] ?? '';
              }
            }

            if (_address.accessible != null) {
              if(_init['Address'] != null) {
                _init['Address']['Accessible'] = _address.accessible;
              } 
            }

            bool _cityExist = false;
            _city.forEach((v) {
              if (v['Name'].toString() == _init['Address_city'].toString()) {
                _cityExist = true;
              }
            });

            if (!_cityExist) {
              _init['Address_city'] = '';
            }

            _bankAccounts.forEach((v) {
              _init['BankAccounts_' + v['AXID'].toString()] =
                  v['AccountNumber'];
            });

            _taxes.forEach((v) {
              _init['Taxes_' + v['AXID'].toString()] = v['NPWP'];
            });

            _electronicAddressType.forEach((v) {
              _init['ElectronicAddresses_' + v['Type'].toString()] = '';
            });

            _electronicAddresses.forEach((v) {
              _init['ElectronicAddresses_' + v['Type'].toString()] =
                  v['Locator'];
            });

            _identificationType.forEach((v) {
              _init['Identifications_' + v['Type'].toString()] = '';
            });

            _identifications.forEach((v) {
              _init['Identifications_' + v['Type'].toString()] = v['Number'];

              if (v['IssueDate'] != null) {
                DateTime _validityStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
                    .parse(v['IssueDate'], false)
                    .toLocal();

                _init['IdentificationsStartPicker_' + v['Type'].toString()] =
                    _validityStart;
              } else {
                _init['IdentificationsStartPicker_' + v['Type'].toString()] =
                    DateTime.now();
              }

              if (v['ExpiredDate'] != null) {
                DateTime _validityFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
                    .parse(v['expiredDate'], false)
                    .toLocal();

                _init['IdentificationsFinishPicker_' + v['Type'].toString()] =
                    _validityFinish;
              } else {
                _init['IdentificationsFinishPicker_' + v['Type'].toString()] =
                    DateTime.now();
              }
            });

            if (_change.isEmpty) {
              _init.forEach((k, v) {
                _change[k.toString()] = false;
              });
            }

            if (_upload.isEmpty) {
              _init.forEach((k, v) {
                _upload[k.toString()] = 0;
              });
            }

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
                       'Status',
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
                        AppLocalizations.of(context).translate('EmployeeID'),
                        'EmployeeID',
                        FormBuilderTextField(
                          name: 'EmployeeID',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('EmployeeID'),
                            suffixIcon: _attachFile(
                              'EmployeeID',
                              onPressed: () {},
                            ),
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
                        AppLocalizations.of(context).translate('Name'),
                        'EmployeeName',
                        FormBuilderTextField(
                          name: 'EmployeeName',
                          decoration: InputDecoration(
                            // labelText:
                            //     AppLocalizations.of(context).translate('Name'),
                            suffixIcon: _attachFile(
                              'EmployeeName',
                              onPressed: () {},
                            ),
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
                        AppLocalizations.of(context).translate('Religion'),
                        'ReligionDescription',
                        FormBuilderDropdown<String>(
                          name: 'ReligionDescription',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('Religion'),
                            suffixIcon: _attachFile(
                              'ReligionDescription',
                              onPressed: () {},
                            ),
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
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('BirthDate'),
                        'BirthdatePicker',
                        FormBuilderDateTimePicker(
                          name: 'BirthdatePicker',
                          inputType: InputType.date,
                          format: DateFormat('dd MMM yyyy'),
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('BirthDate'),
                            suffixIcon: _attachFile(
                              'BirthdatePicker',
                              onPressed: () {},
                            ),
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
                        AppLocalizations.of(context).translate('BirthPlace'),
                        'Birthplace',
                        FormBuilderTextField(
                          name: 'Birthplace',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('BirthPlace'),
                            suffixIcon: _attachFile(
                              'Birthplace',
                              onPressed: () {},
                            ),
                          ),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(context),
                          // ]),
                          onChanged: (val) {},
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Gender'),
                        'GenderDescription',
                        FormBuilderDropdown<String>(
                          name: 'GenderDescription',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('Gender'),
                            suffixIcon: _attachFile(
                              'GenderDescription',
                              onPressed: () {},
                            ),
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
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('MaritalStatus'),
                        'MaritalStatusDescription',
                        FormBuilderDropdown<String>(
                          name: 'MaritalStatusDescription',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('MaritalStatus'),
                            suffixIcon: null,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _maritalStatus
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _change['MaritalStatusDescription'] = true;
                              _upload['MaritalStatusDescription'] = 0;
                            });
                          },
                          valueTransformer: (String? val) => val.toString(),
                          enabled: false,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                      SizedBox(height: 10),
                      FormBuilderCheckbox(
                        name: 'IsExpatriate',
                        title: Text(
                          AppLocalizations.of(context).translate('Expatriate'),
                        ),
                        onChanged: (val) {},
                        enabled: false,
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Address'),
                        'Address_street',
                        FormBuilderTextField(
                          name: 'Address_street',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('Address'),
                            suffixIcon: _attachFile(
                              'Address_street',
                              onPressed: () {
                                _fileUpload(
                                  'Address',
                                  _init['Address'],
                                );
                              },
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {
                            setState(() {
                              _change['Address_street'] = true;
                              _upload['Address_street'] = 0;
                            });
                          },
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('City'),
                        'Address_city',
                        FormBuilderDropdown<String>(
                          name: 'Address_city',
                          decoration: InputDecoration(
                            // labelText: AppLocalizations.of(context)
                            //     .translate('City'),
                            suffixIcon: null,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _city
                              .map((item) => DropdownMenuItem(
                                    value: item['Name'].toString(),
                                    child: Text(item['Name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _change['Address_street'] = true;
                              _upload['Address_street'] = 0;
                            });
                          },
                          onTap: () {
                            Navigator.pop(_formKey.currentContext!);
                            AppListSearch(context).show(
                              _city,
                              value: 'Id',
                              label: 'Name',
                              select: (val) {
                                _formKey.currentState?.fields['Address_city']!
                                    .didChange(val['Name'].toString());
                              },
                            );
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      for (var item in _bankAccounts)
                        Column(children: [
                          _formInputGroup(
                            AppLocalizations.of(context)
                                    .translate('BankAccount') +
                                ' (${item['Name']})',
                            'BankAccounts_' + item['AXID'].toString(),
                            FormBuilderTextField(
                              name: 'BankAccounts_' + item['AXID'].toString(),
                              decoration: InputDecoration(
                                // labelText: AppLocalizations.of(context)
                                //     .translate('BankAccount'),
                                suffixIcon: _attachFile(
                                  'BankAccounts_' + item['AXID'].toString(),
                                  onPressed: () {
                                    _fileUpload(
                                      'BankAccounts',
                                      item,
                                    );
                                  },
                                ),
                              ),
                              // validator: FormBuilderValidators.compose([
                              //   FormBuilderValidators.required(context),
                              // ]),
                              onChanged: (val) {
                                setState(() {
                                  _change['BankAccounts_' +
                                      item['AXID'].toString()] = true;
                                  _upload['BankAccounts_' +
                                      item['AXID'].toString()] = 0;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ]),
                      for (var item in _electronicAddressType)
                        Column(children: [
                          _formInputGroup(
                            item['Description'],
                            'ElectronicAddresses_' + item['Type'].toString(),
                            FormBuilderTextField(
                              name: 'ElectronicAddresses_' +
                                  item['Type'].toString(),
                              decoration: InputDecoration(
                                // labelText: item['description'],
                                suffixIcon: _attachFile(
                                  'ElectronicAddresses_' +
                                      item['Type'].toString(),
                                  onPressed: () {
                                    Map<String, dynamic> val = {
                                      'Type': item['Type'],
                                      'TypeDescription': item['Description']
                                    };

                                    _electronicAddresses.forEach((v) {
                                      if (v['Type'].toString() ==
                                          item['Type'].toString()) {
                                        val = v;
                                      }
                                    });

                                    _fileUpload(
                                      'ElectronicAddresses',
                                      val,
                                    );
                                  },
                                ),
                              ),
                              // validator: FormBuilderValidators.compose([
                              //   FormBuilderValidators.required(context),
                              // ]),
                              onChanged: (val) {
                                setState(() {
                                  _change['ElectronicAddresses_' +
                                      item['Type'].toString()] = true;
                                  _upload['ElectronicAddresses_' +
                                      item['Type'].toString()] = 0;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ]),
                      for (var item in _identificationType)
                        Column(children: [
                          _formInputGroup(
                            item['Type'],
                            'Identifications_' + item['Type'].toString(),
                            FormBuilderTextField(
                              name:
                                  'Identifications_' + item['Type'].toString(),
                              decoration: InputDecoration(
                                // labelText: item['Type'],
                                suffixIcon: _attachFile(
                                  'Identifications_' + item['Type'].toString(),
                                  onPressed: () {
                                    Map<String, dynamic> val = {
                                      'Type': item['Type'],
                                      'Description': item['Description']
                                    };

                                    _identifications.forEach((v) {
                                      if (v['Type'].toString() ==
                                          item['Type'].toString()) {
                                        val = v;
                                      }
                                    });

                                    _fileUpload(
                                      'Identifications',
                                      val,
                                    );
                                  },
                                ),
                              ),
                              // validator: FormBuilderValidators.compose([
                              //   FormBuilderValidators.required(context),
                              // ]),
                              onChanged: (val) {
                                setState(() {
                                  _change['Identifications_' +
                                      item['Type'].toString()] = true;
                                  _upload['Identifications_' +
                                      item['Type'].toString()] = 0;
                                });
                              },
                            ),
                          ),
                          (item['Type'] == 'KITAS/KITAP')
                              ? SizedBox(height: 10)
                              : Container(),
                          (item['Type'] == 'KITAS/KITAP')
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _formInputGroup(
                                        AppLocalizations.of(context)
                                            .translate('IssuingDate'),
                                        'IdentificationsStartPicker_' +
                                            item['Type'].toString(),
                                        FormBuilderDateTimePicker(
                                          name: 'IdentificationsStartPicker_' +
                                              item['Type'].toString(),
                                          inputType: InputType.date,
                                          format: DateFormat('dd MMM yyyy'),
                                          decoration: InputDecoration(
                                              // labelText: AppLocalizations.of(context)
                                              //     .translate('IssuingDate'),
                                              ),
                                          // validator:
                                          //     FormBuilderValidators.compose([
                                          //   FormBuilderValidators.required(
                                          //       context),
                                          // ]),
                                          onChanged: (val) {
                                            setState(() {
                                              _change['Identifications_' +
                                                      item['Type'].toString()] =
                                                  true;
                                              _upload['Identifications_' +
                                                  item['Type'].toString()] = 0;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _formInputGroup(
                                        AppLocalizations.of(context)
                                            .translate('ExpirationDate'),
                                        'IdentificationsFinishPicker_' +
                                            item['Type'].toString(),
                                        FormBuilderDateTimePicker(
                                          name: 'IdentificationsFinishPicker_' +
                                              item['Type'].toString(),
                                          inputType: InputType.date,
                                          format: DateFormat('dd MMM yyyy'),
                                          decoration: InputDecoration(
                                              // labelText: AppLocalizations.of(context)
                                              //     .translate('ExpirationDate'),
                                              ),
                                          // validator: FormBuilderValidators.compose([
                                          //   FormBuilderValidators.required(context),
                                          // ]),
                                          onChanged: (val) {
                                            setState(() {
                                              _change['Identifications_' +
                                                      item['Type'].toString()] =
                                                  true;
                                              _upload['Identifications_' +
                                                  item['Type'].toString()] = 0;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(height: 10),
                        ]),
                      for (var item in _taxes)
                        Column(children: [
                          _formInputGroup(
                            AppLocalizations.of(context).translate('NPWP'),
                            'Taxes_' + item['AXID'].toString(),
                            FormBuilderTextField(
                              name: 'Taxes_' + item['AXID'].toString(),
                              decoration: InputDecoration(
                                // labelText: AppLocalizations.of(context)
                                //     .translate('NPWP'),
                                suffixIcon: _attachFile(
                                  'Taxes_' + item['AXID'].toString(),
                                  onPressed: () {
                                    _fileUpload(
                                      'Taxes',
                                      item,
                                    );
                                  },
                                ),
                              ),
                              // validator: FormBuilderValidators.compose([
                              //   FormBuilderValidators.required(context),
                              // ]),
                              onChanged: (val) {
                                setState(() {
                                  _change['Taxes_' + item['AXID'].toString()] =
                                      true;
                                  _upload['Taxes_' + item['AXID'].toString()] =
                                      0;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ]),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.file_download,
                                //color: (_init['Address']['Accessible'])
                                color: (_init['Address'] != null)
                                    ? null
                                    : Theme.of(context).disabledColor,
                              ),
                              Text(
                                'File Address',
                                //style: (_init['Address']['Accessible'])
                                style: (_init['Address'] != null)
                                    ? null
                                    : TextStyle(
                                        color: Theme.of(context).disabledColor),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (_init['Address'] != null) {
                            //if (_init['Address']['Accessible']) {
                              // globals.launchInBrowser(
                              //   '${globals.apiUrl}/employee/address/download/${_init['employeeID']}/${_init['address']['axid']}',
                              // );

                              Navigator.pushNamed(
                                context,
                                Routes.downloader,
                                arguments: {
                                  'name': 'File Address',
                                  'link':
                                      '${globals.apiUrl}/employee/address/download/${_init['EmployeeID']}/${_init['Address']['AXID']}',
                                },
                              );
                            }
                          },
                        ),
                      ),
                      for (var item in _bankAccounts)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.file_download,
                                  color: (item['Accessible'])
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                                Text(
                                  'File Bank Account',
                                  style: (item['Accessible'])
                                      ? null
                                      : TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (item['accessible']) {
                                // globals.launchInBrowser(
                                //   '${globals.apiUrl}/employee/bankAccount/download/${_init['employeeID']}/${item['axid']}',
                                // );

                                Navigator.pushNamed(
                                  context,
                                  Routes.downloader,
                                  arguments: {
                                    'name':
                                        'File Bank Account (${item['Name']})',
                                    'link':
                                        '${globals.apiUrl}/employee/bankAccount/download/${_init['EmployeeID']}/${item['AXID']}',
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      for (var item in _electronicAddresses)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.file_download,
                                  color: (item['Accessible'])
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                                Text(
                                  'File ${item['TypeDescription']}',
                                  style: (item['Accessible'])
                                      ? null
                                      : TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (item['Accessible']) {
                                // globals.launchInBrowser(
                                //   '${globals.apiUrl}/employee/electronicAddress/download/${_init['employeeID']}/${item['axid']}',
                                // );

                                Navigator.pushNamed(
                                  context,
                                  Routes.downloader,
                                  arguments: {
                                    'name': 'File ${item['Description']}',
                                    'link':
                                        '${globals.apiUrl}/employee/electronicAddress/download/${_init['EmployeeID']}/${item['AXID']}',
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      for (var item in _identifications)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.file_download,
                                  color: (item['Accessible'])
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                                Text(
                                  'File ${item['Type']}',
                                  style: (item['Accessible'])
                                      ? null
                                      : TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (item['Accessible']) {
                                // globals.launchInBrowser(
                                //   '${globals.apiUrl}/employee/identification/download/${_init['employeeID']}/${item['axid']}',
                                // );

                                Navigator.pushNamed(
                                  context,
                                  Routes.downloader,
                                  arguments: {
                                    'name': 'File ${item['Type']}',
                                    'link':
                                        '${globals.apiUrl}/employee/identification/download/${_init['EmployeeID']}/${item['AXID']}',
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      for (var item in _taxes)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.file_download,
                                  color: (item['Accessible'])
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                                Text(
                                  'File NPWP',
                                  style: (item['Accessible'])
                                      ? null
                                      : TextStyle(
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (item['Accessible']) {
                                // globals.launchInBrowser(
                                //   '${globals.apiUrl}/employee/tax/download/${_init['employeeID']}/${item['axid']}',
                                // );

                                Navigator.pushNamed(
                                  context,
                                  Routes.downloader,
                                  arguments: {
                                    'name': 'File NPWP',
                                    'link':
                                        '${globals.apiUrl}/employee/tax/download/${_init['EmployeeID']}/${item['AXID']}',
                                  },
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                )
              : AppLoading();
        },
      ),
    );
  }

  Widget _formInputGroup(String label, String name, Widget formInput) {
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
            (_change[name] == true)
                ? Text('*', style: TextStyle(color: Colors.teal))
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

  Widget? _attachFile(String name, {void Function()? onPressed}) {
    Icon _icon;
    Color _color;

    switch (_upload[name]) {
      case 1:
        _icon = Icon(
          Icons.file_download_done,
          color: Colors.black.withOpacity(0.5),
        );
        _color = Colors.green.withOpacity(0.5);
        break;
      case 2:
        _icon = Icon(
          Icons.attach_file,
          color: Colors.black.withOpacity(0.5),
        );
        _color = Colors.red.withOpacity(0.5);
        break;
      case 3:
        _icon = Icon(
          Icons.hourglass_bottom,
          color: Colors.black.withOpacity(0.5),
        );
        _color = Colors.orange.withOpacity(0.5);
        break;
      default:
        _icon = Icon(
          Icons.attach_file,
          color: Colors.black.withOpacity(0.5),
        );
        _color = Colors.yellow.withOpacity(0.5);
    }

    return (_change[name] == true)
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _color,
            ),
            child: IconButton(
              icon: _icon,
              onPressed: onPressed,
            ),
          )
        : null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<EmployeeModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

       _val.forEach((k, v) {
        if(k == 'Readonly') _readonly = v ?? true;
        if(k == 'TrackingStatusDescription') _trackingStatusDesc = v ?? 'InReview';
      });

      return EmployeeModel.fromJson(_val);
    }

    return null;
  }

  void _fileUpload(String module, Map<String, dynamic> value) async {
    Map<String, dynamic> data = {};
    bool success = false;
    String name = '';
    String route = '';

    if (module == 'Address') {
      AddressModel().toJson().forEach((k, v) {
        data[k] = (!value.containsKey(k)) ? v : value[k];
      });

      data['Street'] = _formKey.currentState?.fields['Address_street']!.value;
      data['City'] = _formKey.currentState?.fields['Address_city']!.value;

      name = 'Address_street';
      route = 'MSaveAddress';
    }

    if (module == 'BankAccounts') {
      BankAccountModel().toJson().forEach((k, v) {
        data[k] = (!value.containsKey(k)) ? v : value[k];
      });

      data['AccountNumber'] = _formKey.currentState!
          .fields['BankAccounts_' + data['AXID'].toString()]!.value;

      name = 'BankAccounts_' + data['AXID'].toString();
      route = 'MSaveBankAccount';
    }

    if (module == 'Taxes') {
      TaxModel().toJson().forEach((k, v) {
        data[k] = (!value.containsKey(k)) ? v : value[k];
      });

      data['NPWP'] = _formKey
          .currentState!.fields['Taxes_' + data['AXID'].toString()]!.value;

      name = 'Taxes_' + data['AXID'].toString();
      route = 'MSaveTax';
    }

    if (module == 'Identifications') {
      IdentificationModel().toJson().forEach((k, v) {
        data[k] = (!value.containsKey(k)) ? v : value[k];
      });

      data['Number'] = _formKey.currentState!
          .fields['Identifications_' + data['Type'].toString()]!.value;

      data['IssuingAggency'] ??= '';
      data['IsPrimary'] ??= 0;

      data['IssueDate'] = '1900-01-01T12:00:00';
      data['ExpiredDate'] = '1900-01-01T12:00:00';

      if (_formKey.currentState!.fields[
              'IdentificationsStartPicker_' + data['Type'].toString()] !=
          null) {
        data['IssueDate'] = _formKey
            .currentState!
            .fields['IdentificationsStartPicker_' + data['Type'].toString()]!
            .value
            .add(Duration(hours: 7))
            .toIso8601String();
      }

      if (_formKey.currentState!.fields[
              'IdentificationsFinishPicker_' + data['Type'].toString()] !=
          null) {
        data['ExpiredDate'] = _formKey
            .currentState!
            .fields['IdentificationsFinishPicker_' + data['Type'].toString()]!
            .value
            .add(Duration(hours: 7))
            .toIso8601String();
      }

      int _issueDate =
          int.parse(data['IssueDate'].substring(0, 10).replaceAll('-', ''));
      int _expiredDate =
          int.parse(data['ExpiredDate'].substring(0, 10).replaceAll('-', ''));

      if (_expiredDate < _issueDate) {
        AppSnackBar.danger(
            context, 'Expiration Date should be greater than Issuing Date');
        return;
      }

      name = 'Identifications_' + data['Type'].toString();
      route = 'MSaveIdentification';
    }

    if (module == 'ElectronicAddresses') {
      ElectronicAddressModel().toJson().forEach((k, v) {
        data[k] = (!value.containsKey(k)) ? v : value[k];
      });

      data['Locator'] = _formKey.currentState!
          .fields['ElectronicAddresses_' + data['Type'].toString()]!.value;

      name = 'ElectronicAddresses_' + data['Type'].toString();
      route = 'MSaveElectronicAddress';
    }

    if (data.isNotEmpty) {
      data['AXID'] ??= -1;
      data['AXRequestID'] ??= null;
      data['Action'] ??= 0;
      data['Accessible'] ??= false;
      data['Status'] ??= 0;
      data['StatusDescription'] ??= 'InReview';
      data['LastUpdate'] ??= '0001-01-01T00:00:00';
      data['CreatedDate'] ??= '0001-01-01T00:00:00';
      data['EmployeeID'] = globals.appAuth.user?.id;
      data['EmployeeName'] = globals.appAuth.user?.fullName;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withReadStream: true,
      );

      if (result != null) {
        PlatformFile file = result.files.single;

        setState(() {
          _upload[name] = 3;
        });

        ApiResponse<dynamic> upload = await _resumeService.fileUpload(
          route,
          file,
          JsonEncoder().convert(data),
        );

        if (upload.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, upload.message);
          success = false;
        }

        if (upload.status == ApiStatus.COMPLETED) {
          if (upload.data['StatusCode'] == 200) {
            AppSnackBar.success(context, upload.data['message'].toString());
            success = true;
          }

          if (upload.data['StatusCode'] == 400) {
            AppSnackBar.danger(context, upload.data['message'].toString());
            success = false;
          }
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _upload[name] = (success) ? 1 : 2;
          });
        });
      }
    }
  }
}
