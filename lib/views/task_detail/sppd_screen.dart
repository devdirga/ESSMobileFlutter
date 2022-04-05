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
import 'package:ess_mobile/services/travel_service.dart';
import 'package:ess_mobile/services/master_service.dart';
import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/travel_model.dart';

class SppdDetail extends StatefulWidget {
  @override
  _SppdDetailState createState() => _SppdDetailState();
}

class _SppdDetailState extends State<SppdDetail> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TravelService _travelService = TravelService();
  final MasterService _masterService = MasterService();

  Future<TravelModel?>? _formValue;
  List<Map<String, dynamic>> _travelPurpose = [];
  List<Map<String, dynamic>> _travelTransportation = [];
  PlatformFile? _filePicker;
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

    _masterService.travelTransportation().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _travelTransportation = [];

          v.data.data.forEach((i) {
            _travelTransportation.add(i.toJson());
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

    _masterService.travelPurpose().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _travelPurpose = [];

          v.data.data.forEach((i) {
            _travelPurpose.add(i.toJson());
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
        title: Text(AppLocalizations.of(context).translate('TravelRequest')),
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
      child: FutureBuilder<TravelModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {
            'note': '',
          };

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            if (_init['transportationDescription'] == null ||
                _init['transportationDescription'] == '') {
              _travelTransportation.forEach((v) {
                if (v['axid'].toString() ==
                    _init['transportation'].toString()) {
                  _init['transportationDescription'] = v['description'];
                }
              });
            } else {
              bool _transportExist = false;
              _travelTransportation.forEach((v) {
                if (v['axid'].toString() ==
                    _init['transportation'].toString()) {
                  _transportExist = true;
                }
              });

              if (!_transportExist) {
                _init['transportation'] = null;
                _init['transportationDescription'] = null;
              }
            }

            if (_init['travelPurposeDescription'] == null ||
                _init['travelPurposeDescription'] == '') {
              _travelPurpose.forEach((v) {
                if (v['axid'].toString() == _init['travelPurpose'].toString()) {
                  _init['travelPurposeDescription'] = v['description'];
                }
              });
            } else {
              bool _purposeExist = false;
              _travelPurpose.forEach((v) {
                if (v['axid'].toString() == _init['travelPurpose'].toString()) {
                  _purposeExist = true;
                }
              });

              if (!_purposeExist) {
                _init['travelPurpose'] = null;
                _init['travelPurposeDescription'] = null;
              }
            }

            if (_init['travelPurpose'] == 0) {
              _init['travelPurpose'] = null;
              _init['travelPurposeDescription'] = null;
            }

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

            _init['filePicker'] = '';
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
                        AppLocalizations.of(context).translate('StartTime'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'scheduleStartPicker',
                          inputType: InputType.both,
                          format: DateFormat('EEEE, dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('StartTime'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('EndTime'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'scheduleFinishPicker',
                          inputType: InputType.both,
                          format: DateFormat('EEEE, dd MMM yyyy HH:mm'),
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('EndTime'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Origin'),
                        true,
                        FormBuilderTextField(
                          name: 'origin',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Origin'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Destination'),
                        true,
                        FormBuilderTextField(
                          name: 'destination',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Destination'),
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
                            .translate('Transportation'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'transportationDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Transportation'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _travelTransportation
                              .map((item) => DropdownMenuItem(
                                    value: item['description'].toString(),
                                    child: Text(item['description'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Purpose'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'travelPurposeDescription',
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Purpose'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _travelPurpose
                              .map((item) => DropdownMenuItem(
                                    value: item['description'].toString(),
                                    child: Text(item['description'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          onTap: () {
                            Navigator.pop(_formKey.currentContext!);
                            AppListSearch(context).show(
                              _travelPurpose,
                              value: 'axid',
                              label: 'description',
                              select: (val) {
                                _formKey.currentState!
                                    .fields['travelPurposeDescription']!
                                    .didChange(val['description'].toString());
                              },
                            );
                          },
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Note'),
                        false,
                        FormBuilderTextField(
                          name: 'note',
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
                                  .translate('TravelDocument'),
                              true,
                              FormBuilderTextField(
                                name: 'filePicker',
                                decoration: InputDecoration(
                                  // labelText: AppLocalizations.of(context)
                                  //     .translate('TravelDocument'),
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
                                                .fields['filePicker']!
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
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Detail SPPD',
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
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: _init['sppd'].length,
                        itemBuilder: (BuildContext context, int index) {
                          SppdModel sppd =
                              SppdModel.fromJson(_init['sppd'][index]);
                          List<Map<String, dynamic>> sppdItems = [];

                          if (sppd.ticket != null && sppd.ticket! > 0)
                            sppdItems.add({
                              'name': 'Ticket',
                              'value':
                                  globals.formatCurrency.format(sppd.ticket)
                            });

                          if (sppd.accommodation != null &&
                              sppd.accommodation! > 0)
                            sppdItems.add({
                              'name': 'Accommodation',
                              'value': globals.formatCurrency
                                  .format(sppd.accommodation)
                            });

                          if (sppd.rent != null && sppd.rent! > 0)
                            sppdItems.add({
                              'name': 'Vehicle Rental Fee',
                              'value': globals.formatCurrency.format(sppd.rent)
                            });

                          if (sppd.airportTransportation != null &&
                              sppd.airportTransportation! > 0)
                            sppdItems.add({
                              'name': 'Airport Transportation',
                              'value': globals.formatCurrency
                                  .format(sppd.airportTransportation)
                            });

                          if (sppd.localTransportation != null &&
                              sppd.localTransportation! > 0)
                            sppdItems.add({
                              'name': 'Local Transportation',
                              'value': globals.formatCurrency
                                  .format(sppd.localTransportation)
                            });

                          if (sppd.pocketMoney != null && sppd.pocketMoney! > 0)
                            sppdItems.add({
                              'name': 'Allowance',
                              'value': globals.formatCurrency
                                  .format(sppd.pocketMoney)
                            });

                          if (sppd.mealAllowance != null &&
                              sppd.mealAllowance! > 0)
                            sppdItems.add({
                              'name': 'Meal Allowance',
                              'value': globals.formatCurrency
                                  .format(sppd.mealAllowance)
                            });

                          if (sppd.laundry != null && sppd.laundry! > 0)
                            sppdItems.add({
                              'name': 'Laundry',
                              'value':
                                  globals.formatCurrency.format(sppd.laundry)
                            });

                          if (sppd.fuel != null && sppd.fuel! > 0)
                            sppdItems.add({
                              'name': 'Fuel',
                              'value': globals.formatCurrency.format(sppd.fuel)
                            });

                          if (sppd.highway != null && sppd.highway! > 0)
                            sppdItems.add({
                              'name': 'Toll Road Fee',
                              'value':
                                  globals.formatCurrency.format(sppd.highway)
                            });

                          if (sppd.parking != null && sppd.parking! > 0)
                            sppdItems.add({
                              'name': 'Parking Fee',
                              'value':
                                  globals.formatCurrency.format(sppd.parking)
                            });

                          return Card(
                            child: ExpansionTile(
                              title: Text(
                                sppd.sppdid.toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              initiallyExpanded: (index == 0) ? true : false,
                              children: <Widget>[
                                for (var item in sppdItems)
                                  ListTile(
                                    title: Text(item['name'].toString()),
                                    trailing: Text(item['value'].toString()),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      (_readonly)
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.file_download,
                                      color: (_init['accessible'])
                                          ? null
                                          : Theme.of(context).disabledColor,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('DownloadTravelDocument'),
                                      style: (_init['accessible'])
                                          ? null
                                          : TextStyle(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  if (_init['accessible']) {
                                    // globals.launchInBrowser(
                                    //   '${globals.apiUrl}/travel/download/${_init['employeeID']}/${_init['travelID']}',
                                    // );

                                    Navigator.pushNamed(
                                      context,
                                      Routes.downloader,
                                      arguments: {
                                        'name':
                                            'Travel Document (${_init['travelPurposeDescription']})',
                                        'link':
                                            '${globals.apiUrl}/travel/download/${_init['employeeID']}/${_init['travelID']}',
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),
                      Container(),
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

  Future<TravelModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'readonly') {
          _readonly = v ??= true;
        }
      });

      return TravelModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    TravelModel _data = TravelModel();

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
      _data.intention ??= 0;
      _data.intentionDescription ??= 'Self';
      _data.isGuest ??= false;
      _data.needPassportExtension ??= false;
      _data.needVisaExtension ??= false;
      _data.transactionDate ??= '0001-01-01T00:00:00';
      _data.closedDate ??= '0001-01-01T00:00:00';
      _data.canceledDate ??= '0001-01-01T00:00:00';
      _data.verifiedDate ??= '0001-01-01T00:00:00';
      _data.revisionDate ??= '0001-01-01T00:00:00';
      _data.transportasi ??= 0;
      _data.travelRequestStatus ??= 0;
      _data.travelType ??= 0;
      _data.travelTypeDescription ??= 'Domestic';
      _data.origin = value['origin'];
      _data.destination = value['destination'];
      _data.travelPurposeDescription = value['travelPurposeDescription'];
      _data.transportationDescription = value['transportationDescription'];
      _data.note = value['note'].toString().trim();
      _data.reason = '';

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
            context, 'End Time should be greater than Start Time');
        return;
      }

      _travelPurpose.forEach((v) {
        if (v['description'].toString() ==
            _data.travelPurposeDescription.toString()) {
          _data.travelPurpose = int.parse(v['axid'].toString());
        }
      });

      _travelTransportation.forEach((v) {
        if (v['description'].toString() ==
            _data.transportationDescription.toString()) {
          _data.transportation = int.parse(v['axid'].toString());
        }
      });

      if (_filePicker != null) {
        setState(() {
          _disabled = true;
        });

        ApiResponse<dynamic> upload = await _travelService.travelSave(
          (_data.axid == -1) ? 'request' : 'revise',
          _filePicker!,
          JsonEncoder().convert(_data.toJson()),
          _data.reason!,
        );

        if (upload.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, upload.message);
        }

        if (upload.status == ApiStatus.COMPLETED) {
          if (upload.data['statusCode'] == 200) {
            AppSnackBar.success(context, upload.data['message'].toString());
            Navigator.pop(context);
          }

          if (upload.data['statusCode'] == 400) {
            AppSnackBar.danger(context, upload.data['message'].toString());
          }
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _disabled = false;
            _filePicker = null;
            _formKey.currentState!.fields['filePicker']!.didChange('');
          });
        });
      } else {
        AppAlert(context).attachment(
          title: AppLocalizations.of(context).translate('TravelRequest'),
        );
      }
    });
  }
}
