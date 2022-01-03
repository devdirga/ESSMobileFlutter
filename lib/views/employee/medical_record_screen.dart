import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/medical_record_service.dart';
import 'package:ess_mobile/models/medical_record_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  Future<ApiResponse<dynamic>>? _medicalRecords;

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

    _medicalRecords =
        _medicalRecordService.medicalRecords(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('MedicalRecord')),
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
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _medicalRecords,
        builder: (context, snapshot) {
          List<Widget> _children = <Widget>[];

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            var _response = snapshot.data?.data;

            switch (snapshot.data!.status) {
              case ApiStatus.LOADING:
                return AppLoading(
                  loadingMessage: snapshot.data!.message,
                );

              case ApiStatus.COMPLETED:
                if (_response.data.length > 0) {
                  bool _expanded = true;

                  _response.data.sort((a, b) {
                    return a.recordDate
                        .toString()
                        .compareTo(b.recordDate.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    _children.add(_buildExpansionTile(context, v, _expanded));
                    _expanded = false;
                  });
                } else {
                  _children.add(
                    ListTile(
                      title: Center(child: Text('No Data Available')),
                    ),
                  );
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _medicalRecords = _medicalRecordService
                          .medicalRecords(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _medicalRecords = _medicalRecordService
                        .medicalRecords(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: _children,
                )
              : AppLoading();
        },
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    MedicalRecordModel items,
    bool expanded,
  ) {
    DateTime _recordDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.recordDate.toString(), false)
        .toLocal();
    String _title = DateFormat('EEEE, dd MMM yyyy').format(_recordDate);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: (items.documents!.length == 0)
              ? ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: Theme.of(context).primaryTextTheme.caption,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.description!,
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.notes!,
                        style: Theme.of(context).primaryTextTheme.bodyText1,
                      ),
                    ],
                  ),
                )
              : ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: Theme.of(context).primaryTextTheme.caption,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.description!,
                        style: Theme.of(context).primaryTextTheme.subtitle1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.notes!,
                        style: Theme.of(context).primaryTextTheme.bodyText1,
                      ),
                    ],
                  ),
                  initiallyExpanded: expanded,
                  children: [
                    for (var item in items.documents!)
                      ListTile(
                        leading: Icon(
                          Icons.file_download,
                          color: (item.accessible!)
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).disabledColor,
                        ),
                        title: Text(
                          item.filename!,
                          style: Theme.of(context).primaryTextTheme.subtitle1,
                        ),
                        onTap: () async {
                          if (item.accessible!) {
                            // globals.launchInBrowser(
                            //   '${globals.apiUrl}/employee/medicalRecord/download/${globals.appAuth.user?.id}/${items.axid}/${item.axid}',
                            // );
                            //File getFile = await _medicalRecordService.getMedicalRecordFile(item.filehash!, item.filename!); 
                            //if(await getFile.exists()){
                            //  OpenFile.open(getFile.path);
                            //}
                            String _filehash = item.filehash.toString().replaceAll('/', '_');
                            Navigator.pushNamed(
                              context,
                              Routes.downloader,
                              arguments: {
                                'name': 'Medical Record (${item.filename})',
                                'link':
                                    '${globals.apiUrl}/ess/employee/MDownloadMedicalRecord/'+_filehash,
                              },
                            );              
                          }
                        },
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
