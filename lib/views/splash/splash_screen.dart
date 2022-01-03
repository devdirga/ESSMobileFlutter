import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/widgets/logo.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppLogo(size: 120),
            SizedBox(height: 30),
            Text(
              'EMPLOYEE SELF SERVICE',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }

  startTimer() {
    var duration = Duration(milliseconds: 3000);
    return Timer(duration, redirect);
  }

  redirect() async {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }
}
