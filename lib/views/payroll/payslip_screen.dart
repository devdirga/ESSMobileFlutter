import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/payroll_service.dart';
import 'package:ess_mobile/models/payslip_model.dart';

class PayslipScreen extends StatefulWidget {
  @override
  _PayslipScreenState createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  final PayrollService _payrollService = PayrollService();

  Future<ApiResponse<dynamic>>? _payslip;

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

    _payslip = _payrollService.payslip(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Payslip')),
      ),
      main: Padding(
        padding: EdgeInsets.all(5.0),
        child: _container(context),
      ),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _payslip,
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
                  Map<String, List<PayslipModel>> _dataMap = {};

                  _response.data.sort((a, b) {
                    return a.axid.toString().compareTo(b.axid.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    String _title = v.year.toString();

                    if (!_dataMap.containsKey(_title)) {
                      _dataMap[_title] = <PayslipModel>[];
                    }

                    _dataMap[_title]!.add(v);
                  });

                  bool _expanded = true;

                  _dataMap.forEach((k, v) {
                    _children
                        .add(_buildExpansionTile(context, k, v, _expanded));
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
                      _payslip =
                          _payrollService.payslip(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _payslip =
                        _payrollService.payslip(globals.getFilterRequest());
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
    String title,
    List<PayslipModel> items,
    bool expanded,
  ) {
    List<DataRow> _dataRows = <DataRow>[];

    if (items.length > 0) {
      items.forEach((v) {
        _dataRows.add(DataRow(
          cells: _dataCells(v),
        ));
      });
    }

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
          child: ExpansionTile(
            leading: Icon(
              Icons.table_view_sharp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            title: Text(
              title,
              style: Theme.of(context).primaryTextTheme.headline6,
            ),
            initiallyExpanded: expanded,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  child: AppDataTable(
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('ProcessID'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Type'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Period'),
                        ),
                      ),
                      DataColumn(
                        label: Text(''),
                      ),
                    ],
                    rows: _dataRows,
                    columnWidths: {
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FixedColumnWidth(55),
                    },
                  ),
                ),
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

  List<DataCell> _dataCells(PayslipModel item) {
    item.processID ??= '';
    item.cycleTimeDescription ??= '';

    DateTime _monthYear =
        DateFormat('M-yyyy').parse(item.monthYear!, false).toLocal();
    String _period = DateFormat('MMM yyyy').format(_monthYear);

    return <DataCell>[
      DataCell(Text(item.processID.toString())),
      DataCell(Text(item.cycleTimeDescription.toString())),
      DataCell(Text(_period)),
      DataCell(PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: space(10.0, <Widget>[
                Icon(
                  Icons.file_download,
                  color: (item.accessible!)
                      ? null
                      : Theme.of(context).disabledColor,
                ),
                Text(
                  AppLocalizations.of(context).translate('DownloadPayslip'),
                  style: (item.accessible!)
                      ? null
                      : TextStyle(color: Theme.of(context).disabledColor),
                ),
              ]),
            ),
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            if (item.accessible!) {
              // globals.launchInBrowser(
              //   '${globals.apiUrl}/payroll/payslip/download/${globals.appAuth.user?.id}/${item.processID}',
              // );

              Navigator.pushNamed(
                context,
                Routes.downloader,
                arguments: {
                  'name': 'Payslip (${item.cycleTimeDescription}, $_period)',
                  'link':
                      '${globals.apiUrl}/ess/payroll/MDownloadPayslip/${globals.appAuth.user?.id}/${item.processID}/${item.filename}',
                },
              );
            }
          }
        },
      )),
    ];
  }
}
