import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/medical_record_service.dart';
import 'package:ess_mobile/models/medical_record_model.dart';

class MedicalRecord extends StatefulWidget {
  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  Future<ApiResponse<dynamic>>? _medicalRecords;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {});

    _medicalRecords =
        _medicalRecordService.medicalRecords(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).translate('MedicalRecord'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.navigate_next, color: Colors.white),
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.medicalRecord),
                  ),
                ],
              ),
            ),
          ),
          _container(context),
        ],
      ),
    );
  }

  Widget _container(BuildContext context) {
    return FutureBuilder<ApiResponse<dynamic>>(
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
                bool _expanded = false;

                _response.data.sort((a, b) {
                  return a.recordDate
                      .toString()
                      .compareTo(b.recordDate.toString());
                });

                int i = 0;

                _response.data.reversed.forEach((v) {
                  if (i < 3) {
                    _children.add(_buildExpansionTile(context, v, _expanded));
                    _expanded = false;
                  }

                  i++;
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
      padding: EdgeInsets.only(bottom: 0.0),
      child: Container(
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
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
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.description!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.notes!,
                        style: Theme.of(context).textTheme.bodyText1,
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
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.description!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        items.notes!,
                        style: Theme.of(context).textTheme.bodyText1,
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
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).disabledColor,
                        ),
                        title: Text(
                          item.filename!,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onTap: () {
                          if (item.accessible!) {
                            // globals.launchInBrowser(
                            //   '${globals.apiUrl}/employee/medicalRecord/download/${globals.appAuth.user?.id}/${items.axid}/${item.axid}',
                            // );

                            Navigator.pushNamed(
                              context,
                              Routes.downloader,
                              arguments: {
                                'name': 'Medical Record (${item.filename})',
                                'link':
                                    '${globals.apiUrl}/ess/employee/MGetMedicalRecords/${globals.appAuth.user?.id}/${items.axid}/${item.axid}',
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
