import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:file_picker/file_picker.dart';
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

class ComplaintDetail extends StatefulWidget {
  @override
  _ComplaintDetailState createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends State<ComplaintDetail> {
  final ComplaintService _complaintService = ComplaintService();
  final MasterService _masterService = MasterService();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<ComplaintModel?>? _formValue;
  List<Map<String, dynamic>> _ticketCategory = [];
  PlatformFile? _filePicker;
  bool _disabled = true;
  bool _readonly = true;
  String _trackingStatusDesc = 'InReview';
  List<Map<String, dynamic>> _listType = [];

  List<Map<String, dynamic>> _listMedia = [
    { 'ID': 0, 'Name': 'Email' },
	  { 'ID': 1, 'Name': 'Telephone' },
	  { 'ID': 2, 'Name': 'WalkInCustomer' },
	  { 'ID': 3, 'Name': 'Other' }
  ];

  List<String> _listStatus = ['Open', 'Progress', 'Closed'];

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
          ? Text(AppLocalizations.of(context).translate('TicketDetail'))
          : Text(AppLocalizations.of(context).translate('TicketRequest'))
        ,
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
                  _saveComplaint(_formKey.currentState!.value);
                } else {
                  AppSnackBar.danger(
                    context,
                    'Please enter all required fields.',
                  );
                }
              }
            },
        )
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
            _init['TrackingStatusDescription'] = _trackingStatusDesc;
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
                      (_readonly)
                        ? _formInputGroup(
                            AppLocalizations.of(context).translate('OpenTicketDate'),
                            true,
                            FormBuilderDateTimePicker(
                              name: 'CreatedDate',
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
                          )
                        : Container(),
                      (_readonly) ? SizedBox(height: 10) : Container(),
                      (_readonly)
                        ? _formInputGroup(
                            AppLocalizations.of(context).translate('ClosedTicketDate'),
                            true,
                            FormBuilderDateTimePicker(
                              name: 'ClosedDate',
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
                          )
                        : Container(),
                      (_readonly) ? SizedBox(height: 10) : Container(),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Type'),
                        true,
                        FormBuilderDropdown<String>(
                          name: 'TicketType',
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
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          items: _listMedia
                              .map((item) => DropdownMenuItem(
                                    value: item['ID'].toString(),
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
                          decoration: InputDecoration(
                              // labelText: AppLocalizations.of(context)
                              //     .translate('Relationship'),
                              ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
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
                      (_readonly) ? SizedBox(height: 10) : Container(),
                      (_readonly)
                        ? _formInputGroup(
                            AppLocalizations.of(context).translate('Requester'),
                            true,
                            FormBuilderTextField(
                              name: 'FullName',
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                              ]),
                              onChanged: (val) {},
                            ),
                          )
                        : Container(),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Subject'),
                        true,
                        FormBuilderTextField(
                          name: 'Subject',
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
                          onChanged: (val) {},
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                        ),
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Description'),
                        true,
                        FormBuilderTextField(
                          name: 'Description',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                          maxLines: 3,
                        ),
                      ),
                      (_readonly) ? SizedBox(height: 10) : Container(),
                      (_readonly)
                        ? _formInputGroup(
                            AppLocalizations.of(context).translate('TicketStatus'),
                            true,
                            Chip(
                              label: Text(_listStatus[_init['TicketStatus']]),
                            )
                          )
                        : Container(),
                      SizedBox(height: 10),
                      (!_readonly)
                          ? _formInputGroup(
                              AppLocalizations.of(context)
                                  .translate('Attachment'),
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

  Future<ComplaintModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if(k == 'Readonly') _readonly = v ?? true;
        if(k == 'TrackingStatusDescription') _trackingStatusDesc = v ?? 'InReview';
      });

      return ComplaintModel.fromJson(_val);
    }

    return null;
  }

  void _saveComplaint(Map<String, dynamic> value) async {
    ComplaintModel _data = ComplaintModel();

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
      _data.invertedStatus ??= 0;
      _data.invertedStatusDescription ??= '';
      _data.lastUpdate ??= '0001-01-01T00:00:00';
      _data.createdDate ??= '0001-01-01T00:00:00';
      _data.closedDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;
      _data.fullName = globals.appAuth.user?.fullName;
      _data.subject = value['Subject'].toString().trim();
      _data.emailCc = '[\"'+ value['EmailCC'].toString().trim() + '\"]';
      _data.emailFrom = globals.appAuth.user!.email.toString();
      _data.description = value['Description'].toString().trim();
      _data.ticketDate = DateTime.now().toUtc().toIso8601String();
      _data.ticketType = int.parse(value['TicketType']);
      _data.ticketMedia = int.parse(value['TicketMedia']);
      _data.ticketStatus = 0;
      _data.ticketCategory = null;
      _data.emailTo = [];
      
      _ticketCategory.forEach((v) {
        if (v['Id']!.toString() == value['Category_id'].toString()) {
          _data.category = TicketCategoryModel.fromJson(v);
          _data.emailTo!.add(v['Contacts'][0]['Email']);
        }
      });
     
      if (_filePicker != null) {
        AppAlert(context).save(
          title: AppLocalizations.of(context).translate('TicketRequest'),
          yes: (String? val) async {
            _data.reason = val.toString().trim();

            setState(() {
              _disabled = true;
            });

            ApiResponse<dynamic> upload =
                await _complaintService.complaintSave(
              _filePicker!,
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
                _filePicker = null;
                _formKey.currentState!.fields['FilePicker']!.didChange('');
              });
            });
          },
        );
      } else {
        AppAlert(context).attachment(
          title: AppLocalizations.of(context).translate('TicketRequest'),
        );
      }
    });
  }
}
