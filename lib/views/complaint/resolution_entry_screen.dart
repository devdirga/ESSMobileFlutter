import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/models/complaint_model.dart';
import 'package:ess_mobile/models/ticket_category_model.dart';
import 'package:ess_mobile/services/complaint_service.dart';
import 'package:ess_mobile/services/master_service.dart';

class ResolutionEntryScreen extends StatefulWidget {
  @override
  _ResolutionEntryScreenState createState() => _ResolutionEntryScreenState();
}

class _ResolutionEntryScreenState extends State<ResolutionEntryScreen> {
  final ComplaintService _complaintService = ComplaintService();
  final MasterService _masterService = MasterService();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<ComplaintModel?>? _formValue;
  List<Map<String, dynamic>> _ticketCategory = [];
  List<Map<String, dynamic>> _listType = [];
  List<Map<String, dynamic>> _listMedia = [];
  List<Map<String, dynamic>> _listUpdateStatus = [];
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

    _masterService.ticketType().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _listType = [];

          v.data.data.forEach((i) {
            _listType.add(i);
          });
        }
      }
    });

    _masterService.ticketMedia().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _listMedia = [];

          v.data.data.forEach((i) {
            _listMedia.add(i);
          });
        }
      }
    });

    _masterService.ticketStatus().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _listUpdateStatus = [];

          v.data.data.forEach((i) {
            _listUpdateStatus.add(i);
          });
        }
      }
    });

    _complaintService.ticketCategories().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _ticketCategory = [];
          v.data.data.forEach((i) {
            _ticketCategory.add(i.toJson()); 
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
        title: _readonly 
          ? Text(AppLocalizations.of(context).translate('ResolutionDetail'))
          : Text(AppLocalizations.of(context).translate('ResolutionUpdate'))
        ,
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
      navigationBar: (!_readonly)
        ? BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.cancel),
              label: 'Cancel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.save_sharp),
              label: 'Update',
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
                  _updateComplaint(_formKey.currentState!.value);
                } else {
                  AppSnackBar.danger(
                    context,
                    'Please enter all required fields.',
                  );
                }
              }
            },
          ) 
        : null
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ComplaintModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();

            
            if (_init['CreatedDate'] != null) {
              DateTime _createdDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['CreatedDate'], false)
                  .toLocal();

              _init['CreatedDate'] = _createdDate;
            }

            if (_init['ClosedDate'] != null) {
              if (_init['ClosedDate'] == '0001-01-01T00:00:00Z'){
                _init['ClosedDate'] = null;
              }
              else{
                DateTime _closedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .parse(_init['ClosedDate'], false)
                  .toLocal();

                _init['ClosedDate'] = _closedDate;
              }
            }

            _init['FilePicker'] = '';
            _init['TicketMedia'] = _init['TicketMedia'].toString();
            _init['TicketType'] = _init['TicketType'].toString();
            _init['TicketStatus'] = _init['TicketStatus'].toString();

            _init['Category_id'] = null;

            if(_init['Category'] != null){
              _init['Category_id'] = _init['Category']['Id'];
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
                        AppLocalizations.of(context).translate('OpenTicketDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'CreatedDate',
                          enabled: false,
                          inputType: InputType.both,
                          format: DateFormat('dd-MM-yyyy HH:mm'),
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
                        AppLocalizations.of(context).translate('ClosedTicketDate'),
                        true,
                        FormBuilderDateTimePicker(
                          name: 'ClosedDate',
                          enabled: false,
                          inputType: InputType.both,
                          format: DateFormat('dd-MM-yyyy HH:mm'),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Type'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'TicketType',
                          enabled: false,
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _listType
                              .map((item) => DropdownMenuItem(
                                    value: item['Value'].toString(),
                                    child: Text(item['Name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Media'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'TicketMedia',
                          enabled: false,
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _listMedia
                              .map((item) => DropdownMenuItem(
                                    value: item['Value'].toString(),
                                    child: Text(item['Name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Category'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'Category_id',
                          enabled: false,
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          /*validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),*/
                          items: _ticketCategory
                              .map((item) => DropdownMenuItem(
                                    value: item['Id'].toString(),
                                    child: Text(item['Name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Requester'),
                        true,
                        FormBuilderTextField(
                          name: 'FullName',
                          enabled: false,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Subject'),
                        true,
                        FormBuilderTextField(
                          name: 'Subject',
                          enabled: false,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('EmailCC'),
                        true,
                        FormBuilderTextField(
                          name: 'EmailCC',
                          enabled: false,
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Description'),
                        true,
                        FormBuilderTextField(
                          name: 'Description',
                          enabled: false,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Status'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'TicketStatus',
                          enabled: !_readonly,
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _listUpdateStatus
                              .map((item) => DropdownMenuItem(
                                    value: item['Value'].toString(),
                                    child: Text(item['Name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (val) {},
                          valueTransformer: (String? val) => val.toString(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('TicketResolution'),
                        true,
                        FormBuilderTextField(
                          name: 'TicketResolution',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
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
                                    'DownloadFile'),
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
                                        '(${_init['TicketNumber']}) File',
                                    'link':
                                        '${globals.apiUrl}/ess/complaint/MDownload/${_init['Id']}/${_init['Filename']}',
                                  },
                              );
                            }
                          },
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

  Future<ComplaintModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'Readonly') {
          _readonly = v ??= true;
        }
      });

      return ComplaintModel.fromJson(_val);
    }

    return null;
  }

  void _updateComplaint(Map<String, dynamic> value) async {
    ComplaintModel _data = ComplaintModel();

    _formValue?.then((val) async {
      if (val != null) {
        _data = val;
      }

      _data.axid ??= -1;
      _data.axRequestID ??= null;
      _data.action ??= 0;
      _data.ticketStatus = int.parse(value['TicketStatus']);
      _data.ticketResolution = value['TicketResolution'].toString().trim();
      _data.emailTo = [];
      
      _ticketCategory.forEach((v) {
        if (v['Id']!.toString() == value['Category_id'].toString()) {
          _data.category = TicketCategoryModel.fromJson(v);
          _data.emailTo!.add(v['Contacts'][0]['Email']);
        }
      });
     
      setState(() {
        _disabled = true;
        _loading = true;
      });

      AppAlert(context).save(
        title: AppLocalizations.of(context).translate('TicketResolution'),
        yes: (String? val) async {
          _data.reason = val.toString().trim();

          setState(() {
            _disabled = true;
          });

          ApiResponse<dynamic> upload =
              await _complaintService.updateStatus(
            JsonEncoder().convert(_data.toJson())
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
            });
          });
        },
      );
    });
  }
}
