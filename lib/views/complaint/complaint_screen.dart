import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/datepicker.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/complaint_service.dart';
import 'package:ess_mobile/models/complaint_model.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final ComplaintService _complaintService = ComplaintService();
  TextEditingController _filterDateStart = TextEditingController();
  TextEditingController _filterDateEnd = TextEditingController();
  TextEditingController _filterSubject = TextEditingController();
  TextEditingController _filterTicketNumber = TextEditingController();
  String _ticketStatus = '';
  String _ticketType = '';
  
  Future<ApiResponse<dynamic>>? _complaints;
  List<ComplaintModel> _listComplaint = <ComplaintModel>[];
  List<String> _listType = ['Complaint', 'Question', 'Incident', 'FutureRequest'];
  List<String> _listStatus = ['Open', 'Progress', 'Closed'];

  int? _sortColumnIndex;
  bool _isAscending = false;

  List<Map<String, dynamic>> _listObjType = [
    { 'ID': 0, 'Name': 'Complaint' },
	  { 'ID': 1, 'Name': 'Question' },
	  { 'ID': 2, 'Name': 'Incident' },
	  { 'ID': 3, 'Name': 'FutureRequest' }
  ];

  List<Map<String, dynamic>> _listUpdateStatus = [
    { 'ID': 0, 'Name': 'Open' },
	  { 'ID': 1, 'Name': 'Progress' },
	  { 'ID': 2, 'Name': 'Closed' }
  ];
  
  Map<String, dynamic> getValue = {
    'Start':
        DateTime.now().subtract(Duration(days: 8, hours: 7)).toIso8601String(),
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

    Future.delayed(Duration.zero, () async {
      setState(() {
        _sortColumnIndex = 0;
        _complaints = _complaintService
            .complaints(globals.getFilterRequest(params: getValue));
      });
    });
     
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Ticket')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        download: () {
          _downloadExcel();
        },
        create: () {
          Navigator.pushNamed(
            context,
            Routes.complaintEntry
          ).then((val) {
            setState(() {
              _complaints = _complaintService
                  .complaints(globals.getFilterRequest());
            });
          });
        },
        filter: () { 
          _showFilterDialog(context);
        },
        refresh: () {
          setState(() {
            _sortColumnIndex = 0;
            _complaints = _complaintService
                .complaints(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _complaints,
        builder: (context, snapshot) {
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

                  if(_sortColumnIndex == 0) {
                    _listComplaint.clear();
                  }

                  if(_listComplaint.length == 0){
                    _response.data.reversed.forEach((v) {
                      if(v.ticketNumber != null) {
                        _listComplaint.add(v);
                      }
                    });
                  }
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _sortColumnIndex = 0;
                      _complaints = _complaintService
                          .complaints(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _sortColumnIndex = 0;
                    _complaints = _complaintService
                        .complaints(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
            ? Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: (_listComplaint.length > 0) ? DataTable(
                  columnSpacing: 4.0,
                  horizontalMargin: 6.0,
                  headingRowHeight: 36.0,
                  sortAscending: _isAscending,
                  sortColumnIndex: _sortColumnIndex,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Ticket'),
                      ),
                      onSort: _onSort
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Type'),
                      ),
                      onSort: _onSort
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Stat'),
                      ),
                      onSort: _onSort
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context).translate('Open'),
                      ),
                      onSort: _onSort
                    ),
                    DataColumn(
                      label: Text(''),
                    )
                  ],
                  rows: _listComplaint
                  .asMap().map(
                    (i, comp) => MapEntry(i, DataRow(
                      cells: _dataCells(comp),
                      color: i.isEven 
                      ? MaterialStateProperty.all(Colors.grey.withOpacity(0.3))
                      : MaterialStateProperty.all(Colors.white)
                    ))
                  )
                  .values.toList(),
                )
                : Container(),
              ),
          )
          : AppLoading();
        },
      ),
    );
  }

  @override
  void dispose() {
    _filterDateStart.dispose();
    _filterDateEnd.dispose();
    _filterSubject.dispose();
    _filterTicketNumber.dispose();

    super.dispose();
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      _listComplaint.sort((comp1, comp2) =>
          compareString(ascending, '${comp1.ticketNumber}', '${comp2.ticketNumber}'));
    } else if (columnIndex == 1) {
      _listComplaint.sort((comp1, comp2) =>
          compareString(ascending, '${comp1.ticketType}', '${comp2.ticketType}'));
    } else if (columnIndex == 2) {
      _listComplaint.sort((comp1, comp2) =>
          compareString(ascending, '${comp1.ticketStatus}', '${comp2.ticketStatus}'));
    } else if (columnIndex == 3) {
      _listComplaint.sort((comp1, comp2) =>
          compareString(ascending, '${comp1.createdDate}', '${comp2.createdDate}'));
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  void _showFilterDialog(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: space(10.0, <Widget>[
              Icon(Icons.filter),
              Text(
                AppLocalizations.of(context).translate('Filter'),
              ),
            ]),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autocorrect: false,
                    controller: _filterTicketNumber,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('TicketNumber'),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    controller: _filterSubject,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('Subject'),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('Type'),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                    items: _listObjType
                        .map((item) => DropdownMenuItem(
                        value: item['ID'].toString(),
                        child: Text(item['Name'].toString()),
                      ))
                    .toList(),
                    onChanged: (value) {
                      setState(() {
                        _ticketType = value.toString();
                      });
                    }
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('Status'),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                    //value: _value,
                    items: _listUpdateStatus
                        .map((item) => DropdownMenuItem(
                        value: item['ID'].toString(),
                        child: Text(item['Name'].toString()),
                      ))
                    .toList(),
                    onChanged: (value) {
                      setState(() {
                        _ticketStatus = value.toString();
                      });
                    }
                  ),
                  TextFormField(
                    autocorrect: false,
                    controller: _filterDateStart,
                    onTap: () {
                      AppDatePicker(context, setState).show(_filterDateStart);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    maxLines: 1,
                    validator: (value) => (value!.isEmpty || value.length < 1)
                        ? AppLocalizations.of(context).translate('ChooseDate')
                        : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('OpenDateFrom'),
                      icon: Icon(Icons.calendar_today),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    controller: _filterDateEnd,
                    onTap: () {
                      AppDatePicker(context, setState).show(_filterDateEnd);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    maxLines: 1,
                    validator: (value) => (value!.isEmpty || value.length < 1)
                        ? AppLocalizations.of(context).translate('ChooseDate')
                        : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('OpenDateTo'),
                      icon: Icon(Icons.calendar_today),
                      labelStyle: TextStyle(
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context).translate('Cancel'),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context).translate('Filter'),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () async {
                _filterComplaints();
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  void _filterComplaints(){
    List<Map<String, dynamic>> _filterData = [];
    if(_filterSubject.text != ''){
      _filterData.add({
        "field": "Subject",
        "operator": "contains",
        "value": _filterSubject.text
      });
    }
    if(_filterTicketNumber.text != ''){
      _filterData.add({
        "field": "TicketNumber",
        "operator": "contains",
        "value": _filterTicketNumber.text
      });
    }
    if(_ticketStatus != ''){
      _filterData.add({
        "field": "TicketStatus",
        "operator": "eq",
        "value": _ticketStatus
      });
    }
    if(_ticketType != ''){
      _filterData.add({
        "field": "TicketType",
        "operator": "eq",
        "value": _ticketType
      });
    }
    if(_filterDateStart.text != ''){
      _filterData.add({
        "field": "CreatedDate",
        "operator": "gte",
        "value": DateFormat('dd/MM/yyyy')
          .parse(_filterDateStart.text)
          .subtract(Duration(hours: 7))
          .toIso8601String()
      });
    }
    if(_filterDateEnd.text != ''){
      _filterData.add({
        "field": "CreatedDate",
        "operator": "lte",
        "value": DateFormat('dd/MM/yyyy')
          .parse(_filterDateEnd.text)
          .subtract(Duration(hours: 7))
          .toIso8601String()
      });
    }
    if(_filterData.length > 0){
      getValue["Filter"] =  {
        "logic": "and",
        "filters": _filterData
      };
    }

    setState(() {
      _sortColumnIndex = 0;
      _complaints = _complaintService
          .complaints(globals.getFilterRequest(params: getValue));
    });

    _filterDateStart.clear();
    _filterDateEnd.clear();
    _filterSubject.clear();
    _filterTicketNumber.clear();
    _ticketStatus = '';
    _ticketType = '';
  }

  void _downloadExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1']; 
    List _status = ['Open', 'Progress', 'Closed'];
    List _type = ['Complaint', 'Question', 'Incident', 'FutureRequest'];

    sheetObject.appendRow(['Ticket Number', 'Subject', 'Type', 'Status', 'Open Ticket Date', 'Close Ticket Date']);
    
    _listComplaint.forEach((comp) {
      DateTime _open = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(comp.createdDate!, false)
        .toLocal();
     
      String _openDate = DateFormat('dd-MM-yyyy HH:mm').format(_open);

      String _closeDate = '-';
      if(comp.closedDate != '0001-01-01T00:00:00Z'){
        DateTime _close = DateFormat('yyyy-MM-ddTHH:mm:ss')
          .parse(comp.closedDate!, false)
          .toLocal();
        _closeDate = DateFormat('dd-MM-yyyy HH:mm').format(_close);
      }
      
      sheetObject.appendRow([comp.ticketNumber, comp.subject, 
        _type[comp.ticketType!], _status[comp.ticketStatus!],
        _openDate, _closeDate ]);
    });

    var directory = await getApplicationDocumentsDirectory();
      
    File file = File(directory.path+"/Tickets.xlsx");
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

  List<DataCell> _dataCells(ComplaintModel item) {
    /*item.project ??= '';
    item.absenceCode ??= '';
    item.absenceCodeDescription ??= '';*/

    List _status = ['Open', 'Progress', 'Closed'];
    List _type = ['Complaint', 'Question', 'Incident', 'FutureRequest'];
    List<Color> _colorStatus = [
      Colors.blue,
      Colors.green,
      Colors.black
    ];
    List<Color> _colorType = [
      Colors.black,
      Colors.green,
      Colors.red,
      Colors.green
    ];
    List<IconData> _iconStatus = [
      Icons.meeting_room,
      Icons.update,
      Icons.door_front_door
    ];
    List<IconData> _iconType = [
      Icons.feedback,
      Icons.contact_support,
      Icons.warning,
      Icons.reviews
    ];

    DateTime _createdDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.createdDate!, false)
        .toLocal();
    
    TextStyle? _textStyle = TextStyle(
      color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    return <DataCell>[
      DataCell(
        item.subject.toString().length > 14 
        ? Text(item.ticketNumber.toString()+'\n'+item.subject.toString().substring(0,12)+'..', style: _textStyle)
        : Text(item.ticketNumber.toString()+'\n'+item.subject.toString(), style: _textStyle)
      ),
      DataCell(Text(_listType[item.ticketType!], style: _textStyle)),
      //DataCell(Text(_listStatus[item.ticketStatus!], style: _textStyle)),
      /*DataCell(Tooltip(
        message: _type[item.ticketType!],
        preferBelow: false,
        child: CircleAvatar(
          radius: 14,
          backgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          child: Icon(_iconType[item.ticketType!], color: _colorType[item.ticketType!]),
        ),
      )),*/
      DataCell(Tooltip(
        message: _status[item.ticketStatus!],
        preferBelow: false,
        child: CircleAvatar(
          radius: 14,
          backgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          child: Icon(_iconStatus[item.ticketStatus!], color: _colorStatus[item.ticketStatus!]),
        ),
      )),
      DataCell(Text(DateFormat('dd-MM-yyyy\nHH:mm').format(_createdDate),
          style: _textStyle)),
      //DataCell(Text(DateFormat('EEEE').format(_loggedDate), style: _textStyle)),
      //DataCell(Text(_scheduledDate.replaceAll('00:00', ''), style: _textStyle)),
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
                  AppLocalizations.of(context).translate('ShowDetail'),
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
              Routes.complaintEntry,
              arguments: _item,
            ).then((val) {
              setState(() {
                _complaints = _complaintService.complaints(globals.getFilterRequest());
              });
            });
          }
        },
      )),
    ];
  }

   int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);
}
