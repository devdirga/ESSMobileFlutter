import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/models/agenda_model.dart';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TimeManagementService _agendaService = TimeManagementService();

  Future<ApiResponse<dynamic>>? _agenda;

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

    _agenda = _agendaService.agenda(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Agenda')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _agenda =
                  _agendaService.agenda(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _agenda = _agendaService.agenda(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
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
                  _response.data.forEach((v) {
                    _dataRows.add(DataRow(
                      cells: _dataCells(v),
                    ));
                  });
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _agenda =
                          _agendaService.agenda(globals.getFilterRequest());
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
                      label: Text(''),
                    ),
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
                    )
                  ],
                  rows: _dataRows,
                  columnWidths: {
                    0: FixedColumnWidth(55),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(145)
                  },
                )
              : AppLoading();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(AgendaModel item) {
    item.description ??= '';
    item.location ??= '';

    /*DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();
    String _scheduledDate =
        DateFormat('dd MMM yyyy').format(_scheduledDateStart) +
            ' - ' +
            DateFormat('dd MMM yyyy').format(_scheduledDateFinish);
    */

    return <DataCell>[
      DataCell(PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: space(10.0, <Widget>[
                Icon(Icons.remove_red_eye),
                Text(
                  AppLocalizations.of(context).translate('ShowAgenda'),
                ),
              ]),
            ),
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            Map<String, dynamic> _item = item.toJson();
            _item['Readonly'] = true;

            Navigator.pushNamed(
              context,
              Routes.agendaDetail,
              arguments: _item,
            ).then((val) {
              setState(() {
                _agenda = _agendaService.agenda(globals.getFilterRequest());
              });
            });
          }
        },
      )),
      DataCell(Text(item.name.toString())),
      DataCell(Text(item.updateBy.toString().replaceAll('@ ', '\n'))),
    ];
  }
}
