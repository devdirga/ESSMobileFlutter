import 'package:flutter/material.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/models/agenda_model.dart';

class AgendaItems extends StatefulWidget {
  @override
  _AgendaItemsState createState() => _AgendaItemsState();
}

class _AgendaItemsState extends State<AgendaItems> {
  final TimeManagementService _agendaService = TimeManagementService();

  Future<ApiResponse<dynamic>>? _agenda;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {});

    _agenda = _agendaService.agenda(globals.getFilterRequest());
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
                      AppLocalizations.of(context).translate('Agenda'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                     child: Icon(Icons.navigate_next, color: Colors.white),
                     onTap: () => Navigator.pushReplacementNamed(
                        context, Routes.agenda),
                  ),
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
      future: _agenda,
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

                _response.data.reversed.forEach((v) {
                  _dataRows.add(DataRow(
                    cells: _dataCells(v),
                  ));
                });
              }

              if (_response.message != null) {
                return AppError(
                  errorMessage: _response.message,
                  onRetryPressed: () => setState(() {
                    _agenda = _agendaService.agenda(globals.getFilterRequest());
                  }),
                );
              }
              break;
            case ApiStatus.ERROR:
              return AppError(
                errorMessage: snapshot.data!.message,
                onRetryPressed: () => setState(() {
                  _agenda = _agendaService.agenda(globals.getFilterRequest());
                }),
              );
          }
        }

        return (snapshot.connectionState == ConnectionState.done)
            ? AppDataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context)
                          .translate('Name'),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      AppLocalizations.of(context).translate('Schedule'),
                    ),
                  ),
                ],
                rows: _dataRows,
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FixedColumnWidth(150)
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

  List<DataCell> _dataCells(AgendaModel item) {
    item.description ??= '';
    
    item.location ??= '';
    /*
    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();
    String _scheduledDate =
        DateFormat('dd-MM-yyyy').format(_scheduledDateStart) +
            ' - ' +
            DateFormat('dd-MM-yyyy').format(_scheduledDateFinish);
    */
    return <DataCell>[
      DataCell(Text(item.name.toString())),
      DataCell(Text(item.updateBy.toString().replaceAll('@ ', '\n'))),
      //DataCell(Text(_scheduledDate.replaceAll('00:00', ''))),
      //DataCell(Text(item.location.toString())),
    ];
  }
}
