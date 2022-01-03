import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double padding;

  AppLogo({Key? key, this.size = 100.0, this.padding = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
