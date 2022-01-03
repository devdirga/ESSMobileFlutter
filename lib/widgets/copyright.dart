import 'package:flutter/material.dart';

class AppCopyright extends StatelessWidget {
  final double vertical;

  AppCopyright({Key? key, this.vertical = 15.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: Text(
          'Copyright © 2021 PT. Terminal Petikemas Surabaya. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.0,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ),
    );
  }
}
