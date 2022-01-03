import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datatable.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/leave_service.dart';
import 'package:ess_mobile/models/leave_model.dart';

class SubordinateScreen extends StatefulWidget {
  final dynamic filterRequest;

  SubordinateScreen(this.filterRequest);

  @override
  _SubordinateScreenState createState() => _SubordinateScreenState();
}

class _SubordinateScreenState extends State<SubordinateScreen> {
  final LeaveService _leaveService = LeaveService();

  Future<ApiResponse<dynamic>>? _subordinate;

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

    _subordinate = _leaveService.subordinate(globals.getFilterRequest());
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
        future: _subordinate,
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
                  Map<String, List<SubordinateModel>> _dataMap = {};

                  _response.data.sort((a, b) {
                    return a.startDate
                        .toString()
                        .compareTo(b.startDate.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    DateTime _startDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                        .parse(v.startDate.toString(), false)
                        .toLocal();
                    String _title = DateFormat('yyyy').format(_startDate);

                    if (!_dataMap.containsKey(_title)) {
                      _dataMap[_title] = <SubordinateModel>[];
                    }

                    _dataMap[_title]!.add(v);
                  });

                  List<Map<String, dynamic>> _dataList = [];

                  _dataMap.forEach((k, v) {
                    _dataList.add({'title': k, 'items': v});
                  });

                  _dataList.sort((a, b) {
                    return a['title']
                        .toString()
                        .compareTo(b['title'].toString());
                  });

                  bool _expanded = true;

                  _dataList.reversed.forEach((v) {
                    _children.add(
                      _buildExpansionTile(
                          context, v['title'], v['items'], _expanded),
                    );
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
                      _subordinate =
                          _leaveService.subordinate(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _subordinate =
                        _leaveService.subordinate(globals.getFilterRequest());
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
    List<SubordinateModel> items,
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
              Icons.list_alt_sharp,
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
                        label: Text(''),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('LeaveDate'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Employee'),
                        ),
                      ),
                      /*DataColumn(
                        label: Text(
                          AppLocalizations.of(context)
                              .translate('EmployeeName'),
                        ),
                      ),*/
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Description'),
                        ),
                      ),
                      /*DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Status'),
                        ),
                      ),*/
                    ],
                    columnWidths: {
                      0: FixedColumnWidth(40),
                      1: FixedColumnWidth(90),
                      2: FixedColumnWidth(90),
                      3: FlexColumnWidth()
                      //4: FixedColumnWidth(85)
                    },
                    rows: _dataRows,
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

  List<DataCell> _dataCells(SubordinateModel item) {
    item.emplId ??= '';
    item.emplName ??= '';
    item.description ??= '';

    DateTime _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.startDate!, false)
        .toLocal();
    DateTime _finish =
        DateFormat('yyyy-MM-ddTHH:mm:ss').parse(item.endDate!, false).toLocal();
    String _leaveDate = DateFormat('dd-MM-yyyy').format(_start) +
        ' - ' +
        DateFormat('dd-MM-yyyy').format(_finish);

    List _status = ['InReview', 'Approved', 'Cancelled', 'Rejected'];
    List<MaterialColor> _colors = [
      Colors.orange,
      Colors.green,
      Colors.blueGrey,
      Colors.red,
    ];
    List<IconData> _icons = [
      Icons.remove_red_eye,
      Icons.check_circle,
      Icons.remove_circle,
      Icons.cancel,
    ];

    return <DataCell>[
      DataCell(Tooltip(
        message: _status[item.status!],
        preferBelow: false,
        child: CircleAvatar(
          radius: 14,
          backgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          child: Icon(_icons[item.status!], color: _colors[item.status!]),
        ),
       )),
      DataCell(Text(_leaveDate)),
      DataCell(Text(item.emplId.toString()+'\n'+item.emplName.toString())),
      DataCell(Container(
        width: 210,
        child: Text(item.description.toString()),
      )),
      /*DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _colors[item.status!],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _status[item.status!],
          style: TextStyle(color: Colors.white),
        ),
      )),*/
    ];
  }
}
