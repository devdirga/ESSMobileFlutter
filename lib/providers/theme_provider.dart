import 'package:flutter/material.dart';
import 'package:ess_mobile/utils/shared_preference.dart';

class ThemeProvider extends ChangeNotifier {
  AppSharedPreference _sharedPrefsHelper = AppSharedPreference();
  bool _isDarkModeOn = false;

  bool get isDarkModeOn {
    _sharedPrefsHelper.isDarkMode.then((statusValue) {
      _isDarkModeOn = statusValue;
    });

    return _isDarkModeOn;
  }

  void updateTheme(bool isDarkModeOn) {
    _sharedPrefsHelper.changeTheme(isDarkModeOn);
    _sharedPrefsHelper.isDarkMode.then((darkModeStatus) {
      _isDarkModeOn = darkModeStatus;
    });

    notifyListeners();
  }
}
