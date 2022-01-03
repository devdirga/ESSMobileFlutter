import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/training_service.dart';
import 'package:ess_mobile/models/training_model.dart';

class HistoryScreen extends StatefulWidget {
  final dynamic filterRequest;

  HistoryScreen(this.filterRequest);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TrainingService _trainingService = TrainingService();

  Future<ApiResponse<dynamic>>? _trainingHistory;

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
  }

  @override
  Widget build(BuildContext context) {
    _trainingHistory = _trainingService.trainingHistory(widget.filterRequest);

    return _container(context);
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _trainingHistory,
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
                      _trainingHistory = _trainingService
                          .trainingHistory(widget.filterRequest);
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _trainingHistory =
                        _trainingService.trainingHistory(widget.filterRequest);
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
              ? AppDataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Training'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('ID'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Schedule'),
                      ),
                    ),
                    DataColumn(
                      label: Text(''),
                    ),
                    DataColumn(
                      label: Text(''),
                    ),
                  ],
                  rows: _dataRows,
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

  List<DataCell> _dataCells(TrainingModel item) {
    item.name ??= '';
    item.location ??= '';
    item.trainingID ??= '';
    item.typeDescription ??= '';
    item.subTypeDescription ??= '';
    item.trainingStatusDescription ??= '';

    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();

    String _scheduledDate = '';

    if (DateFormat('dd MMM yyyy').format(_scheduledDateStart) ==
        DateFormat('dd MMM yyyy').format(_scheduledDateFinish)) {
      if (DateFormat('HH:mm').format(_scheduledDateStart) ==
          DateFormat('HH:mm').format(_scheduledDateFinish)) {
        _scheduledDate =
            DateFormat('EEEE, dd MMM yyyy').format(_scheduledDateStart) +
                ' at ' +
                DateFormat('HH:mm').format(_scheduledDateStart);
      } else {
        _scheduledDate =
            DateFormat('EEEE, dd MMM yyyy').format(_scheduledDateStart) +
                ' at ' +
                DateFormat('HH:mm').format(_scheduledDateStart) +
                ' - ' +
                DateFormat('HH:mm').format(_scheduledDateFinish);
      }
    } else {
      _scheduledDate = DateFormat('EEEE, dd MMM yyyy HH:mm')
              .format(_scheduledDateStart) +
          '\n' +
          DateFormat('EEEE, dd MMM yyyy HH:mm').format(_scheduledDateFinish);
    }

    String description =
        (item.typeDescription! != '' && item.subTypeDescription! != '')
            ? item.typeDescription! + ' - ' + item.subTypeDescription!
            : item.typeDescription!;

    MaterialColor _trainingStatus = Colors.grey;

    switch (item.trainingStatus) {
      case 3:
        _trainingStatus = Colors.orange;
        break;
      case 1:
      case 4:
        _trainingStatus = Colors.indigo;
        break;
      case 2:
        _trainingStatus = Colors.red;
        break;
    }

    Widget _widgetStatus;

    if (item.trainingRegistration != null) {
      MaterialColor _registrationStatus = Colors.grey;

      switch (item.trainingRegistration!.registrationStatus) {
        case 0:
          _registrationStatus = Colors.orange;
          break;
        case 1:
          _registrationStatus = Colors.indigo;
          break;
        case 2:
          _registrationStatus = Colors.green;
          break;
        case 3:
          _registrationStatus = Colors.green;
          break;
        case 4:
          _registrationStatus = Colors.orange;
          break;
        case 5:
          _registrationStatus = Colors.red;
          break;
        case 6:
          break;
      }

      item.trainingRegistration!.registrationStatusDescription ??=
          'NotAvailable';

      _widgetStatus = Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _registrationStatus,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          item.trainingRegistration!.registrationStatusDescription!,
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      _widgetStatus = Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: (item.trainingStatus != 2) ? Colors.lightBlue : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          child: Row(
            children: space(5.0, <Widget>[
              Icon(Icons.login, size: 18, color: Colors.white),
              Text(
                AppLocalizations.of(context).translate('Join'),
                style: TextStyle(color: Colors.white),
              ),
            ]),
          ),
          onTap: () async {
            if (item.trainingStatus != 2) {
              Navigator.pushNamed(
                context,
                Routes.trainingJoin,
                arguments: item.toJson(),
              ).then((val) {
                Navigator.pushReplacementNamed(context, Routes.training);
              });
            }
          },
        ),
      );
    }

    return <DataCell>[
      DataCell(Container(
        width: 210,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.name!,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              item.location!,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      )),
      DataCell(Text(item.trainingID.toString())),
      DataCell(Text(_scheduledDate.replaceAll('00:00', ''))),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _trainingStatus,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          item.trainingStatusDescription!,
          style: TextStyle(color: Colors.white),
        ),
      )),
      DataCell(_widgetStatus),
    ];
  }
}
