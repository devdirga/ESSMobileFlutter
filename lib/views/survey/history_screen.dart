import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/survey_service.dart';
import 'package:ess_mobile/models/survey_model.dart';

class SurveyHistoryScreen extends StatefulWidget {
  final dynamic filterRequest;

  SurveyHistoryScreen(this.filterRequest);

  @override
  _SurveyHistoryScreenState createState() => _SurveyHistoryScreenState();
}

class _SurveyHistoryScreenState extends State<SurveyHistoryScreen> {
  final SurveyService _surveyService = SurveyService();

  Future<ApiResponse<dynamic>>? _history;

  Map<String, dynamic> getValue = {
    'Start':
        DateTime.now().subtract(Duration(days: 60, hours: 7)).toIso8601String(),
    'Finish': DateTime.now().subtract(Duration(days: 1, hours: 7)).toIso8601String(),
  };

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

    _history = _surveyService
            .history(globals.getFilterRequest(params: getValue));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: _container(context),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _history,
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
                if (_response.length > 0) {
                  var indexData = 0;
                  _response.forEach((v) {
                    _dataRows.add(DataRow(
                      cells: _dataCells(v),
                      color: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Even rows will have a grey color.
                        if (indexData.isEven) {
                          return Colors.grey.withOpacity(0.3);
                        }
                        return Colors.white;
                        // Use default value for other states and odd rows.
                      })
                    ));
                    indexData++;
                  });
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _history = _surveyService
                      .history(globals.getFilterRequest(params: getValue));
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
                        AppLocalizations.of(context).translate('Title'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('SurveyDate'),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Score'),
                      ),
                    )
                  ],
                  columnWidths: {
                    0: FixedColumnWidth(55),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(95),
                    3: FixedColumnWidth(60)
                  },
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

  

  List<DataCell> _dataCells(SurveyHistoryModel item) {
    TextStyle? _textStyle = TextStyle(
      color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    DateTime _surveyDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.createDate!, false)
        .toLocal();

    return <DataCell>[
      DataCell(Text('', style: _textStyle)),
      DataCell(Text(item.surveyId![1], style: _textStyle)),
      DataCell(Text(DateFormat('dd/MM/yyyy').format(_surveyDate), style: _textStyle)),
      DataCell(Text(item.quizzScore.toString(), style: _textStyle))
    ];
  }
}