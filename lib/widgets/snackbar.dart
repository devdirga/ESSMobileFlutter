import 'package:flutter/material.dart';

class AppSnackBar {
  static void success(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??= ''),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  static void danger(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??= ''),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void warning(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??= ''),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  static void info(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??= ''),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
