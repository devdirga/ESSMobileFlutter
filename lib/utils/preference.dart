import 'package:hive/hive.dart';

class AppPreferences {
  static const String _preferencesBox = 'essTpsBox';
  static const String auth_user = 'authUser';
  static const String login_data = 'loginData';

  final Box<dynamic> _box;

  AppPreferences._(this._box);

  static Future<AppPreferences> getInstance() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    return AppPreferences._(box);
  }

  T _getValue<T>(dynamic key, {T? defaultValue}) => _box.get(key, defaultValue: defaultValue) as T;
  Future<void> _setValue<T>(dynamic key, T value) => _box.put(key, value);
  Future<void> _removeValue<T>(dynamic key) => _box.delete(key);

  String get authUser => _getValue(auth_user) ?? '';
  Future saveAuthUser(String value) =>  _setValue(auth_user, value);
  Future removeAuthUser() =>  _removeValue(auth_user);

  String get loginData => _getValue(login_data) ?? '';
  Future saveLoginData(String value) =>  _setValue(login_data, value);
  Future removeLoginData() =>  _removeValue(login_data);
}