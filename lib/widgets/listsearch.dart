import 'package:flutter/material.dart';

class AppListSearch {
  final BuildContext context;

  AppListSearch(this.context);

  Future<void> show(
    List<Map<String, dynamic>>? data, {
    String value = 'id',
    String label = 'name',
    Function? select,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (_) {
        return ListSearchDialog(
          data: data,
          value: value,
          label: label,
          select: select,
        );
      },
    );
  }
}

class ListSearchDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? data;
  final String? value;
  final String? label;
  final Function? select;

  ListSearchDialog({
    Key? key,
    this.data,
    this.value,
    this.label,
    this.select,
  }) : super(key: key);

  @override
  _ListSearchDialogState createState() => _ListSearchDialogState();
}

class _ListSearchDialogState extends State<ListSearchDialog> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _data = widget.data!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(10.0),
      contentPadding: EdgeInsets.all(10.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: FractionalOffset.topRight,
            child: GestureDetector(
              child: Icon(Icons.clear),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Here...',
            ),
            onChanged: (val) {
              setState(() {
                _data = widget.data!
                    .where((field) => field[widget.label]
                        .toLowerCase()
                        .contains(val.toLowerCase()))
                    .toList();
              });
            },
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  var item = _data[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item[widget.label].toString()),
                    dense: true,
                    onTap: () async {
                      Navigator.pop(context);

                      if (widget.select != null) {
                        widget.select!(item);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
