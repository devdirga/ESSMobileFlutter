import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSharedPreference {
  Future<SharedPreferences?>? _sharedPreference;
  FlutterSecureStorage? _secureSharedPreference;

  static const String is_logged_in = 'isLoggedIn';
  static const String auth_user = 'authUser';
  static const String is_dark_mode = 'isDarkMode';
  static const String language_code = 'languageCode';
  static const String download_document = 'downloadDocument';
  static const String login_data = 'loginData';
  static const String is_disclaimer_loc = 'isDisclaimerLoc';

  AppSharedPreference() {
    _sharedPreference = SharedPreferences.getInstance();
    _secureSharedPreference = FlutterSecureStorage();
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<String?> get authUser async =>
    await _secureSharedPreference!.read(key: auth_user, aOptions: _getAndroidOptions());
  
  Future saveAuthUser(String value) async =>
      await _secureSharedPreference!.write(key: auth_user, value: value, aOptions: _getAndroidOptions());

  Future removeAuthUser() async =>
      await _secureSharedPreference!.delete(key: auth_user, aOptions: _getAndroidOptions());

  Future<String?> get loginData async =>
    await _secureSharedPreference!.read(key: login_data, aOptions: _getAndroidOptions());
  
  Future saveLoginData(String value) async =>
      await _secureSharedPreference!.write(key: login_data, value: value, aOptions: _getAndroidOptions());

  Future removeLoginData() async =>
      await _secureSharedPreference!.delete(key: login_data, aOptions: _getAndroidOptions());

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
