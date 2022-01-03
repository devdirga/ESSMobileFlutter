import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String? label;
  final void Function()? onPressed;

  AppButton({Key? key, this.label, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Text(label!),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
