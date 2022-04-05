import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/datepicker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';

class AppDateFilter {
  final BuildContext context;

  AppDateFilter(this.context);

  Future<void> show({
    Function? yes,
    Function? cancel,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (_) {
        return DateFilterDialog(yes: yes, cancel: cancel);
      },
    );
  }
}

class DateFilterDialog extends StatefulWidget {
  final Function? yes;
  final Function? cancel;

  DateFilterDialog({Key? key, this.yes, this.cancel}) : super(key: key);

  @override
  _DateFilterDialogState createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<DateFilterDialog> {
  TextEditingController _filterDateStart = TextEditingController();
  TextEditingController _filterDateEnd = TextEditingController();

  DateTime _start = globals.today.subtract(Duration(days: 7));
  DateTime _finish = globals.today;

  @override
  void initState() {
    super.initState();

    if (globals.filterValue.isNotEmpty) {
      if (globals.filterValue.containsKey('Start')) {
        _start = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(globals.filterValue['Start'], true)
            .toLocal();
      }

      if (globals.filterValue.containsKey('Finish')) {
        _finish = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(globals.filterValue['Finish'], true)
            .toLocal();
      }
    }

    _filterDateStart = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_start),
    );

    _filterDateEnd = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_finish),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).translate('Filtering'),
      ),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
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
                  labelText: AppLocalizations.of(context).translate('From'),
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
                  labelText: AppLocalizations.of(context).translate('To'),
                  icon: Icon(Icons.calendar_today),
                  labelStyle: TextStyle(
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
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

            if (widget.cancel != null) {
              widget.cancel!();
            }
          },
        ),
        TextButton(
          child: Text(
            AppLocalizations.of(context).translate('Filter'),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onPressed: () async {
            Map<String, dynamic> getValue = {
              'Start': DateFormat('dd/MM/yyyy')
                  .parse(_filterDateStart.text)
                  //.subtract(Duration(hours: 7))
                  .toIso8601String(),
              'Finish': DateFormat('dd/MM/yyyy')
                  .parse(_filterDateEnd.text)
                  .add(Duration(hours: 23, minutes: 59))
                  //.subtract(Duration(hours: 7))
                  .toIso8601String(),
            };

            Navigator.pop(context);

            if (widget.yes != null) {
              widget.yes!(getValue);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _filterDateStart.dispose();
    _filterDateEnd.dispose();

    super.dispose();
  }
}
