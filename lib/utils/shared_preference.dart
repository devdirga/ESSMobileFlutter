import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {
  Future<SharedPreferences?>? _sharedPreference;

  static const String is_logged_in = 'isLoggedIn';
  static const String is_dark_mode = 'isDarkMode';
  static const String language_code = 'languageCode';
  static const String download_document = 'downloadDocument';
  static const String is_disclaimer_loc = 'isDisclaimerLoc';

  AppSharedPreference() {
    _sharedPreference = SharedPreferences.getInstance();
  }

  // Login
  Future<bool> get isLoggedIn {
    return _sharedPreference!.then((prefs) {
      return prefs?.getBool(is_logged_in) ?? false;
    });
  }

  Future<bool> saveLoggedIn(bool value) {
    return _sharedPreference!.then((prefs) {
      return prefs!.setBool(is_logged_in, value);
    });
  }

  // Theme
  Future<bool> get isDarkMode {
    return _sharedPreference!.then((prefs) {
      return prefs?.getBool(is_dark_mode) ?? false;
    });
  }

  Future<void> changeTheme(bool value) {
    return _sharedPreference!.then((prefs) {
      return prefs?.setBool(is_dark_mode, value);
    });
  }

  // Locale
  Future<String?> get appLocale {
    return _sharedPreference!.then((prefs) {
      return prefs?.getString(language_code) ?? null;
    });
  }

  Future<void> changeLanguage(String value) {
    return _sharedPreference!.then((prefs) {
      return prefs?.setString(language_code, value);
    });
  }

  // Download
  Future<List<String>> get downloadDoc {
    return _sharedPreference!.then((prefs) {
      return prefs?.getStringList(download_document) ?? [];
    });
  }

  Future<void> saveDownloadDoc(List<String> value) {
    return _sharedPreference!.then((prefs) {
      return prefs?.setStringList(download_document, value);
    });
  }

  Future<void> removeDownloadDoc() {
    return _sharedPreference!.then((prefs) {
      return prefs?.remove(download_document);
    });
  }

  // IsDisclaimer
  Future<bool> get isDisclaimerLoc {
    return _sharedPreference!.then((prefs) {
      return prefs?.getBool(is_disclaimer_loc) ?? false;
    });
  }

  Future<bool> saveDisclaimerLoc(bool value) {
    return _sharedPreference!.then((prefs) {
      return prefs!.setBool(is_disclaimer_loc, value);
    });
  }

}
