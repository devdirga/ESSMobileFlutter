import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String loadingMessage;

  AppLoading({Key? key, this.loadingMessage = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.red)
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          )
        ]
      )
    );
  }
}
