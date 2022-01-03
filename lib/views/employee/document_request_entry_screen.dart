import 'dart:convert';
import 'package:ess_mobile/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:ess_mobile/services/document_service.dart';
import 'package:ess_mobile/services/master_service.dart';

class DocumentRequestEntryScreen extends StatefulWidget {
  @override
  _DocumentRequestEntryScreenState createState() => _DocumentRequestEntryScreenState();
}

class _DocumentRequestEntryScreenState extends State<DocumentRequestEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final DocumentService _documentRequestService = DocumentService();
  final MasterService _masterService = MasterService();

  Future<DocumentRequestModel?>? _formValue;
  List<String> _documentRequestType = [];
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

    _masterService.documentRequestType().then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          _documentRequestType = v.data.data;
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
        title: Text(AppLocalizations.of(context).translate('DocumentRequest')),
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
      child: FutureBuilder<DocumentRequestModel?>(
        future: _formValue,
        builder: (context, snapshot) {
          Map<String, dynamic> _init = {};

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            _init = snapshot.data!.toJson();
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
                  AppLocalizations.of(context).translate('DocumentType'),
                  true,
                  FormBuilderDropdown<String>(
                    name: 'DocumentType',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                    items: _documentRequestType
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
                SizedBox(height: 10),
                (!_readonly) ? _formInputGroup(
                  AppLocalizations.of(context)
                      .translate('FileUpload'),
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
                ) : Container(),
              ],
            ),
          ) : AppLoading();
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

  Future<DocumentRequestModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'Readonly') {
          _readonly = v ??= true;
        }
      });

      return DocumentRequestModel.fromJson(_val);
    }

    return null;
  }

  void _update(Map<String, dynamic> value) async {
    DocumentRequestModel _data = DocumentRequestModel();

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
      _data.requestDate ??= '0001-01-01T00:00:00';
      _data.employeeID = globals.appAuth.user?.id;
      _data.employeeName = globals.appAuth.user?.fullName;
      _data.documentType = value['DocumentType'].toString();
      _data.description = value['Description'].toString().trim();
      _data.reason = '';

      if (_filePicker != null) {
        setState(() {
          _loading = true;
          _disabled = true;
        });

        ApiResponse<dynamic> upload = await _documentRequestService.saveDocumentRequest(
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
            _loading = false;
            _formKey.currentState!.fields['FilePicker']!.didChange('');
          });
        });
      } else {
        AppAlert(context).attachment(
          title: AppLocalizations.of(context).translate('Document'),
        );
      }
    });
  }
}
