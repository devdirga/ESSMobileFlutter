import 'dart:math';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/models/loan_type_model.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/loan_request_model.dart';
import 'package:ess_mobile/services/simulasi_pinjaman_service.dart';

class LoanRequestScreen extends StatefulWidget {
  @override
  _LoanRequestScreenState createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final SimulasiPinjamanService _simLoanService = SimulasiPinjamanService();
  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    decimalDigits: 1,
    name: ''
  );

  List<Map<String, dynamic>> _loanTypes = [];
  List<Map<String, dynamic>> _loanMethods = [];
  List<Map<String, dynamic>> _loanPeriods = [];

  Future<LoanRequestModel?>? _formValue;
  double? _latestPayment = 0;
  String _loanTypeId = '';
  String _loanMethodId = '';
  bool _enableCompensation = false;
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

    _getListLoanPeriod();

    _simLoanService.getLoanTypes(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _loanTypes = [];

          v.data.data.forEach((i) {
            setState(() {
              _loanTypes.add(i.toJson());
            });
          });
        }
      }
    });

    _simLoanService.getLoanMethods(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _loanMethods = [];
          v.data.data.forEach((i) {
            setState(() {
              _loanMethods.add(i);
            });
          });
        }
      }
    });

    _simLoanService.getLatestPayslip(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data != null) {
          Map<String, dynamic> rawData = v.data.data.toJson();

          Future.delayed(Duration.zero, () async {
            setState(() {
              _latestPayment = rawData['AmountNetto'];
              _disabled = false;
              _readonly = false;
              _formValue = _arguments();
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('RequestLoan')),
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
      child: FutureBuilder<LoanRequestModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();
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
                    AppLocalizations.of(context).translate('RequestDate'),
                    true,
                    FormBuilderDateTimePicker(
                      name: 'RequestDate',
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      format: DateFormat('dd MMM yyyy'),
                      enabled: false,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      onChanged: (val) {},
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('NetIncome'),
                    true,
                    FormBuilderTextField(
                      name: 'NetIncome',
                      initialValue: _formatter.format(_latestPayment.toString()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [],
                      enabled: false,
                      onChanged: (val) {}
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('LoanType'),
                    true,
                    FormBuilderDropdown<String>(
                      name: 'LoanType',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      items: _loanTypes
                        .map((item) => DropdownMenuItem(
                              value: item['Id'].toString(),
                              child: Text(item['Name'].toString()),
                            ))
                        .toList(),
                      onChanged: (val) {
                        _loanTypeId = val.toString();
                        _loanTypes.forEach((e) {
                          if (e["Id"] == val) {
                            _formKey.currentState!.fields['MaximumLoan']!
                                .didChange(_formatter.format(e["MaximumLoan"].toString()));
                            _formKey.currentState!.fields['LoanValue']!
                                .didChange(_formatter.format(e["MaximumLoan"].toString()));
                          }
                        });
                        _formKey.currentState!.fields['LoanPeriod']!.reset();
                        _getListLoanPeriod();
                        _calculateLoan();
                      },
                      valueTransformer: (String? val) => val.toString(),
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('MaximumLoan'),
                    true,
                    FormBuilderTextField(
                      name: 'MaximumLoan',
                      keyboardType: TextInputType.number,
                      enabled: false,
                      onChanged: (val) {}
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('LoanValue'),
                    true,
                    FormBuilderTextField(
                      name: 'LoanValue',
                      inputFormatters: [ TextInputMask(mask: '9,999,999,999.9', placeholder: '0', maxPlaceHolders: 2, reverse: true)],
                      keyboardType: TextInputType.number,
                      readOnly: false,
                      onChanged: (val) {
                        var _maximumLoan = _formKey.currentState!.fields['MaximumLoan']!.value;
                        if(double.parse(val.toString().replaceAll(',','')) > double.parse(_maximumLoan.toString().replaceAll(',',''))){
                          AppSnackBar.danger(context, 'Loan Value should not be greater than Maximum Loan');
                          return;
                        }
                        _calculateLoan();
                      }
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('LoanMethod'),
                    true,
                    FormBuilderDropdown<String>(
                      name: 'LoanMethod',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      items: _loanMethods
                        .map((item) => DropdownMenuItem(
                              value: item['Id'].toString(),
                              child: Text(item['Name'].toString()),
                            ))
                        .toList(),
                      onChanged: (val) {
                        _formKey.currentState!.fields['CompensationValue']!
                          .didChange('0');
                        
                        if(val == '1') {
                          _enableCompensation = false;
                        }
                        else {
                          _enableCompensation = true;
                        }

                        _loanMethodId = val.toString();
                        _formKey.currentState!.fields['LoanPeriod']!.reset();
                        _getListLoanPeriod();
                        _calculateLoan();
                      },
                      valueTransformer: (String? val) => val.toString(),
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('LoanPeriod'),
                    true,
                    FormBuilderDropdown<String>(
                      name: 'LoanPeriod',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      items: _loanPeriods
                        .map((item) => DropdownMenuItem(
                              value: item["PeriodeName"].toString(),
                              child: Text(item["PeriodeName"]),
                            ))
                        .toList(),
                      onChanged: (val) {
                        _loanPeriods.forEach((e) {
                          if (e['PeriodeName'] == val) {
                            _formKey.currentState!.fields['LoanLength']!
                                .didChange(e['MaximumRangePeriode'].toString());
                            _formKey.currentState!.fields['Interest']!
                                .didChange(e['Interest'].toString()) ;
                            _formKey.currentState!.fields['MaximumRangePeriode']!
                                .didChange(e['MaximumRangePeriode'].toString()) ;
                          }
                        });
                        _calculateLoan();
                      },
                      valueTransformer: (String? val) => val.toString(),
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context).translate('LoanLength'),
                    true,
                    FormBuilderTextField(
                      name: 'LoanLength',
                      keyboardType: TextInputType.number,
                      readOnly: false,
                      onChanged: (val) {
                        _calculateLoan();
                      }
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context)
                        .translate('CompensationValue'),
                    true,
                    FormBuilderTextField(
                      name: 'CompensationValue',
                      inputFormatters: [ TextInputMask(mask: '9,999,999,999.9', placeholder: '0', maxPlaceHolders: 2, reverse: true)],
                      keyboardType: TextInputType.number,
                      enabled: _enableCompensation,
                      onChanged: (val) {
                        _calculateLoan();
                      }
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context)
                        .translate('InstallmentValue'),
                    true,
                    FormBuilderTextField(
                      name: 'InstallmentValue',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      onChanged: (val) {}
                    ),
                  ),
                  SizedBox(height: 10),
                  _formInputGroup(
                    AppLocalizations.of(context)
                        .translate('IncomeAfterInstallment'),
                    true,
                    FormBuilderTextField(
                      name: 'IncomeAfterInstallment',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      onChanged: (val) {}
                    ),
                  ),
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: FormBuilderTextField(
                      name: 'Interest',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      onChanged: (val) {}
                    ),
                  ),
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: FormBuilderTextField(
                      name: 'MaximumRangePeriode',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      onChanged: (val) {}
                    ),
                  )
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

  Future<LoanRequestModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'Readonly') {
          _readonly = v ??= true;
        }
      });

      return LoanRequestModel.fromJson(_val);
    }

    return null;
  }

  void _getListLoanPeriod() async{
    _simLoanService.getLoanPeriods(globals.getFilterRequest()).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          List<Map<String, dynamic>> _listLoanPeriods = [];

          v.data.data.forEach((i) {
            _listLoanPeriods.add(i.toJson());
          });

          if(_loanTypeId != ''){
            _listLoanPeriods = _listLoanPeriods.where((i) => i['IdLoanType'].toString() == _loanTypeId).toList();
          }

          if(_loanMethodId != ''){
            _listLoanPeriods = _listLoanPeriods.where((i) => i['Methode'].toString() == _loanMethodId).toList();
          }

          setState(() {
            _loanPeriods = _listLoanPeriods;
          });
        }
      }
    });
  }

  void _calculateLoan() async{
    var _angsuran = 0.0;
    var _loanValue = double.parse(_formKey.currentState!.fields['LoanValue']!.value.toString().replaceAll(',',''));
    var _periodeLength = double.parse(_formKey.currentState!.fields['LoanLength']!.value != null
      ? _formKey.currentState!.fields['LoanLength']!.value : '1');
    var _netIncome = double.parse(_formKey.currentState!.fields['NetIncome']!.value.toString().replaceAll(',', ''));
    var _compensationValue = double.parse(_formKey.currentState!.fields['CompensationValue']!.value != null
    ? _formKey.currentState!.fields['CompensationValue']!.value.toString().replaceAll(',','') : '0');
    var _interest = double.parse(_formKey.currentState!.fields['Interest']!.value != null
    ? _formKey.currentState!.fields['Interest']!.value : '0.0');

    if (_loanTypeId == '1' && _loanMethodId == '1') {
      _angsuran = _loanValue * (((1 + (_interest * _periodeLength)) / _periodeLength));
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome - _angsuran.round().toDouble()).toString()));
    } else if (_loanTypeId == '1' && _loanMethodId == '2') {
      _angsuran = _loanValue * (((1 + (_interest * _periodeLength)) / _periodeLength));
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome + _compensationValue - _angsuran.round().toDouble()).toString()));
    } else if (_loanTypeId == '2' && _loanMethodId == '1') {
      _angsuran = _loanValue * (((1 + (_interest * _periodeLength)) / _periodeLength));
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome - _angsuran.round().toDouble()).toString()));
    } else if (_loanTypeId == '2' && _loanMethodId == '2') {
      _angsuran = _loanValue * (((1 + (_interest * _periodeLength)) / _periodeLength));
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome + _compensationValue - _angsuran.round().toDouble()).toString()));
    } else if (_loanTypeId == '3' && _loanMethodId == '1') {
      _angsuran = _pmtCalculate(_interest, _periodeLength, _loanValue);
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome + _angsuran.round().toDouble()).toString()));
    } else if (_loanTypeId == "3" && _loanMethodId == '2') {
      _angsuran = _pmtCalculate(_interest, _periodeLength, _loanValue);
      _formKey.currentState!.fields['InstallmentValue']!.didChange(_formatter.format(_angsuran.round().toString()));
      _formKey.currentState!.fields['IncomeAfterInstallment']!.didChange(_formatter.format((_netIncome + _compensationValue + _angsuran.round().toDouble()).toString()));
    }
  }

  _pmtCalculate(double _ratePerPeriod, double _numberOfPayments, double _presentValue) {
    var _futureValue = 0.0; 
    var _type = 0.0; 

    if (_ratePerPeriod != 0.0) {
        // Interest rate exists
        var q = pow(1 + _ratePerPeriod, _numberOfPayments);
        return -(_ratePerPeriod * (_futureValue + (q * _presentValue))) / ((-1 + q) * (1 + _ratePerPeriod * (_type)));

    } else if (_numberOfPayments != 0.0) {
        // No interest rate, but number of payments exists
        return -(_futureValue + _presentValue) / _numberOfPayments;
    }
    return 0;
}

  void _update(Map<String, dynamic> value) async {
    LoanRequestModel _data = LoanRequestModel();

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
      
      _data.amount = 0;
      _data.compensationValue = double.parse(value['CompensationValue'].toString().replaceAll(',',''));
      _data.incomeAfterInstallment = double.parse(value['IncomeAfterInstallment'].toString().replaceAll(',',''));
      _data.installmentValue = double.parse(value['InstallmentValue'].toString().replaceAll(',',''));
      _data.loanValue = double.parse(value['LoanValue'].toString().replaceAll(',',''));
      _data.netIncome = double.parse(value['NetIncome'].toString().replaceAll(',',''));
      _data.periodeLength = int.parse(value['LoanLength']);
      _data.requestDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      _data.type = LoanTypeModel();
      _loanTypes.forEach((e) {
        if(e['Id'] == value['LoanType']){
          _data.type = LoanTypeModel.fromJson(e);
        }
      });

      setState(() {
        _disabled = true;
        _loading = true;
      });
      
      ApiResponse<dynamic> upload = await _simLoanService.saveLoanRequest(_data.toJson());
      
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
          _loading = false;
        });
      });
    });
  }
}
