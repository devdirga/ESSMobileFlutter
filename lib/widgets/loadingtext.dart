import 'package:flutter/material.dart';

class AppLoadingText extends StatelessWidget {
  final String loadingMessage;

  AppLoadingText({Key? key, required this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.blue)
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
