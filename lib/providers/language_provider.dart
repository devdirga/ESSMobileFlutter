import 'package:flutter/material.dart';
import 'package:ess_mobile/utils/shared_preference.dart';

class LanguageProvider extends ChangeNotifier {
  AppSharedPreference _sharedPrefsHelper = AppSharedPreference();
  Locale _appLocale = Locale('en');

  Locale get appLocale {
    _sharedPrefsHelper.appLocale.then((localeValue) {
      if (localeValue != null) {
        _appLocale = Locale(localeValue);
      }
    });

    return _appLocale;
  }

  void updateLanguage(String languageCode) {
    if (languageCode == 'zh') {
      _appLocale = Locale('zh');
    } else {
      _appLocale = Locale('en');
    }

    _sharedPrefsHelper.changeLanguage(languageCode);
    notifyListeners();
  }
}
