import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/models/agenda_model.dart';
import 'package:ess_mobile/services/time_management_service.dart';

class AgendaDetailScreen extends StatefulWidget {
  @override
  _AgendaDetailScreenState createState() => _AgendaDetailScreenState();
}

class _AgendaDetailScreenState extends State<AgendaDetailScreen> {
  final TimeManagementService _agendaService = TimeManagementService();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<AgendaModel?>? _formValue;
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

    Future.delayed(Duration.zero, () async {
          setState(() {
          _readonly = false;
          _formValue = _arguments();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title:
            Text(AppLocalizations.of(context).translate('AgendaDetail')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      )
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<AgendaModel?>(
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
                        AppLocalizations.of(context).translate('Name'),
                        true,
                        FormBuilderTextField(
                          name: 'Name',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
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
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Schedule'),
                        true,
                        FormBuilderTextField(
                          name: 'UpdateBy',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                          ]),
                          onChanged: (val) {},
                        )
                      ),
                      SizedBox(height: 10),
                      _formInputGroup(
                        AppLocalizations.of(context).translate('Notes'),
                        true,
                        Html(
                          data: _init['Notes'],
                          onLinkTap: (url, _, __, ___ ) async {
                            var link = Uri.parse(url.toString()); 
                            if (await canLaunchUrl(link)) {
                              await launchUrl(link);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
                        ),
                      ),
                      for (var item in _init['Attachments']!) 
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: InkWell(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.file_download),
                                  Text(
                                    AppLocalizations.of(context).translate(
                                      'DownloadDocument')
                                  ),
                                ],
                              ),
                              onTap: () async {
                                if (item['Accessible']) {
                                  // globals.launchInBrowser(
                                  //   '${globals.apiUrl}/employee/family/document/download/${_init['employeeID']}/${_init['axid']}',
                                  // );
                                  File getFile = await _agendaService.getAgendaFile(item['Filehash'], item['Filename']); 
                                  if(await getFile.exists()){
                                    OpenFile.open(getFile.path);
                                  }
                                  /*Navigator.pushNamed(
                                    context,
                                    Routes.downloader,
                                    arguments: {
                                      'name':
                                          '${item['Filename']}',
                                      'link':
                                          '${globals.apiUrl}/ess/employee/MDownloadFamilyDocument/${item['EmployeeID']}/${item['AXID']}/${item['Filename']}',
                                    },
                                  );*/
                                }
                              },
                            ),
                          )
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

  Future<AgendaModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;

      _val.forEach((k, v) {
        if (k == 'Readonly') {
          _readonly = v ??= true;
        }
      });

      return AgendaModel.fromJson(_val);
    }

    return null;
  }
}
