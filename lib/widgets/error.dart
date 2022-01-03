import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  final String? errorMessage;
  final void Function()? onRetryPressed;

  AppError({Key? key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent,
            ),
            child: Text('Retry'),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}
