import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final Function? create;
  final Function? filter;
  final Function? refresh;
  final Function? download;

  AppActionButton({
    Key? key,
    this.download,
    this.create,
    this.filter,
    this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: <Widget>[
        Visibility(
          child: Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {
                download!();
              },
              child: Icon(
                Icons.download,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context)
                  .buttonTheme
                  .colorScheme
                  ?.primary
                  .withOpacity(0.9),
              mini: true,
              heroTag: null,
            ),
          ),
          visible: (download != null) ? true : false,
        ),
        Visibility(
          child: Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {
                create!();
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context)
                  .buttonTheme
                  .colorScheme
                  ?.primary
                  .withOpacity(0.9),
              mini: true,
              heroTag: null,
            ),
          ),
          visible: (create != null) ? true : false,
        ),
        Visibility(
          child: Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {
                filter!();
              },
              child: Icon(
                Icons.filter_alt,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context)
                  .buttonTheme
                  .colorScheme
                  ?.primary
                  .withOpacity(0.7),
              mini: true,
              heroTag: null,
            ),
          ),
          visible: (filter != null) ? true : false,
        ),
        Visibility(
          child: Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {
                refresh!();
              },
              child: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context)
                  .buttonTheme
                  .colorScheme
                  ?.primary
                  .withOpacity(0.7),
              mini: true,
              heroTag: null,
            ),
          ),
          visible: (refresh != null) ? true : false,
        ),
      ],
    );
  }
}
