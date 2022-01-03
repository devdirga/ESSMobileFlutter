import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/medical_record_service.dart';
import 'package:ess_mobile/models/medical_record_model.dart';

class MedicalPlafon extends StatefulWidget {
  @override
  _MedicalPlafonState createState() => _MedicalPlafonState();
}

class _MedicalPlafonState extends State<MedicalPlafon> {
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
                      AppLocalizations.of(context).translate('MedicalPlafon'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // InkWell(
                  //   child: Icon(Icons.navigate_next, color: Colors.white),
                  //   onTap: () => print('==='),
                  // ),
                ],
              ),
            ),
          ),
          _dataTable(context),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _dataTable(BuildContext context) {
    return FutureBuilder<ApiResponse<dynamic>>(
      future: _medicalRecords,
      builder: (context, snapshot) {
        List<DataRow> _dataRows = <DataRow>[];

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
                _response.data.sort((a, b) {
                  return a.axid.toString().compareTo(b.axid.toString());
                });

                int i = 0;

                _response.data.reversed.forEach((v) {
                  if (i < 3) {
                    if (i == 0) v.description = 'Pribadi';
                    if (i == 1) v.description = 'Keluarga';
                    if (i == 2) v.description = 'Donasi';

                    _dataRows.add(DataRow(
                      cells: _dataCells(v),
                    ));
                  }

                  i++;
                });
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
            ? AppDataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context).translate('Type'),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context).translate('Limit'),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context).translate('Used'),
                    ),
                  ),
                ],
                rows: _dataRows,
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth()
                },
                headingColor:
                    Theme.of(context).primaryColorDark.withOpacity(0.6),
                headingTextStyle: Theme.of(context).primaryTextTheme.caption,
              )
            : AppLoading();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(MedicalRecordModel item) {
    item.notes ??= '';
    item.description ??= '';

    return <DataCell>[
      DataCell(Text(item.description.toString())),
      DataCell(Text('0', textAlign: TextAlign.right)),
      DataCell(Text('0', textAlign: TextAlign.right)),
    ];
  }
}
