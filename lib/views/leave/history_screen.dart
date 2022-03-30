import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/alert.dart';
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

class HistoryScreen extends StatefulWidget {
  final dynamic filterRequest;

  HistoryScreen(this.filterRequest);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LeaveService _leaveService = LeaveService();

  Future<ApiResponse<dynamic>>? _history;

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

    _history = _leaveService.history(globals.getFilterRequest());
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
                  Map<String, List<LeaveHistoryModel>> _dataMap = {};

                  _response.data.sort((a, b) {
                    return a.schedule.start
                        .toString()
                        .compareTo(b.schedule.start.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    DateTime _startDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                        .parse(v.schedule.start.toString(), false)
                        .toLocal();
                    String _title = DateFormat('yyyy').format(_startDate);

                    if (!_dataMap.containsKey(_title)) {
                      _dataMap[_title] = <LeaveHistoryModel>[];
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
                      _history =
                          _leaveService.history(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _history =
                        _leaveService.history(globals.getFilterRequest());
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
    List<LeaveHistoryModel> items,
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
            leading: TextButton.icon(
              icon: Icon(Icons.file_download, color: Colors.white),
              label: Text(''),
              onPressed: () => _downloadExcel(title, items),
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
                      /*DataColumn(
                        label: Text(''),
                      ),*/
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('LeaveDate'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Description'),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context).translate('Status'),
                        ),
                      ),
                    ],
                    columnWidths: {
                      //0: FixedColumnWidth(40),
                      0: FixedColumnWidth(90),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(85)
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

  void _downloadExcel(String title, List<LeaveHistoryModel> listLeave) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1']; 
    List _status = ['InReview', 'Approved', 'Cancelled', 'Rejected'];

    sheetObject.appendRow(["Leave Date", "Description", "Status"]);
    
    listLeave.forEach((leave) {
      DateTime _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(leave.schedule!.start!, false)
        .toLocal();
      DateTime _finish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(leave.schedule!.finish!, false)
        .toLocal();
      String _leaveDate = DateFormat('dd-MM-yyyy').format(_start) +
        ' - ' + DateFormat('dd-MM-yyyy').format(_finish);
      sheetObject.appendRow([_leaveDate, leave.description, _status[leave.status!]]);
    });

    var directory = await getApplicationDocumentsDirectory();
      
    File file = File(directory.path+"/leave_"+title+".xlsx");
    if (await file.exists()) {
      print("File exist");
      await file.delete().catchError((e) {
        print(e);
      });
    }
    
    var onValue = excel.encode();
    File(file.path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(onValue!);
                              
    if(await file.exists()){
      AppAlert(context).exportExcelAlert(file.path);
    }
  }

  List<DataCell> _dataCells(LeaveHistoryModel item) {
    item.description ??= '';
    
    DateTime _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _finish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();
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
      /*DataCell(CircleAvatar(
        radius: 14,
        backgroundColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
        child: Icon(_icons[item.status!], color: _colors[item.status!]),
      )),*/
      DataCell(Text(_leaveDate)),
      DataCell(Container(
        width: 210,
        child: Text(item.description.toString()),
      )),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _colors[item.status!],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _status[item.status!],
          style: TextStyle(color: Colors.white),
        ),
      )),
    ];
  }
}
