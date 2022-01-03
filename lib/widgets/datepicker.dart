import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;

class AppDatePicker {
  BuildContext? _context;
  void Function(void Function())? _setState;

  AppDatePicker(BuildContext context, void Function(void Function()) setState) {
    _context = context;
    _setState = setState;
  }

  Future show(
    TextEditingController input, {
    String format = 'dd/MM/yyyy',
  }) async {
    DateTime? picked = await showDatePicker(
      context: _context!,
      initialDate: globals.initDateTime,
      firstDate: globals.firstDateTime,
      lastDate: globals.lastDateTime,
    );

    if (picked != null) {
      _setState!(() => {
            input.text = DateFormat(format).format(picked),
          });
    }
  }
}
