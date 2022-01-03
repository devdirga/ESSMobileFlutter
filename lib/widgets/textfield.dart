import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool? obscureText;
  final IconButton? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  AppTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return TextFormField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyText2,
        validator: validator!,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).errorColor,
            ),
          ),
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor,
          ),
        ),
        obscureText: obscureText!,
      );
    } else {
      return TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Theme.of(context).errorColor,
            ),
          ),
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor,
          ),
        ),
        obscureText: obscureText!,
      );
    }
  }
}
