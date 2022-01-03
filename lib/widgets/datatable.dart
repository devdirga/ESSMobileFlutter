import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/providers/theme_provider.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn>? columns;
  final List<DataRow>? rows;
  final double headingRowHeight;
  final double? dataRowHeight;
  final bool dataMode;
  final Map<int, TableColumnWidth>? columnWidths;
  final Color? headingColor;
  final TextStyle? headingTextStyle;

  AppDataTable({
    Key? key,
    this.columns,
    this.rows,
    this.headingRowHeight = 35.0,
    this.dataRowHeight,
    this.dataMode = false,
    this.columnWidths,
    this.headingColor,
    this.headingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    bool _scroll = (columnWidths != null) ? false : true;

    return Stack(children: <Widget>[
      Container(
        width: _width,
        height: headingRowHeight,
        decoration: BoxDecoration(
          color: (headingColor != null)
              ? headingColor
              : Theme.of(context).secondaryHeaderColor,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
      (_scroll == true)
          ? Container(
              width: _width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _dataTable(context),
              ),
            )
          : Container(
              width: _width,
              child: _dataTable(context),
            ),
    ]);
  }

  Widget _dataTable(BuildContext context) {
    return (dataMode)
        ? DataTable(
            headingTextStyle: (headingTextStyle != null)
                ? headingTextStyle
                : Theme.of(context).textTheme.caption,
            headingRowHeight: headingRowHeight,
            dataRowHeight: dataRowHeight,
            horizontalMargin: 15.0,
            columnSpacing: 15.0,
            columns: columns!,
            rows: rows!
          )
        : Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                width: 0.5,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            columnWidths: columnWidths,
            defaultColumnWidth: IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: _rowContent(context)
          );
  }

  List<TableRow> _rowContent(BuildContext context) {
    List<TableRow> _tableRow = <TableRow>[];
    List<Widget> _tableCell = <Widget>[];

    columns!.forEach((v) {
      Text label = Text('');

      if (v.label.runtimeType.toString() == 'Text') {
        label = v.label as Text;
      }

      _tableCell.add(_cellContent(
        Text(
          label.data!,
          style: (headingTextStyle != null)
              ? headingTextStyle
              : Theme.of(context).textTheme.caption,
        ),
        minHeight: headingRowHeight,
        vertical: 0.0,
      ));
    });

    _tableRow.add(TableRow(
      children: _tableCell
    ));

    var rowIndex = 0;
    rows!.forEach((row) {
      _tableCell = <Widget>[];

      row.cells.forEach((v) {
        _tableCell.add(_cellContent(v.child));
      });

      if(rowIndex.isEven){
        _tableRow.add(TableRow(
          children: _tableCell,
          decoration: context.read<ThemeProvider>().isDarkModeOn ? BoxDecoration(color: Colors.grey[800]) : BoxDecoration(color: Colors.grey[200])
        ));
      }
      else {
        _tableRow.add(TableRow(
          children: _tableCell,
          decoration: context.read<ThemeProvider>().isDarkModeOn ? BoxDecoration(color: Colors.grey[600]) : BoxDecoration(color: Colors.grey[50])
        ));
      }

      rowIndex++;
    });

    return _tableRow;
  }

  TableCell _cellContent(
    Widget child, {
    double minHeight = 48.0,
    double vertical: 2.5,
  }) {
    return TableCell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: vertical),
        alignment: Alignment.centerLeft,
        constraints: BoxConstraints(minHeight: minHeight),
        child: child,
      ),
    );
  }
}
