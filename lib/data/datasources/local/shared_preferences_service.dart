// lib/services/shared_preferences_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PrefKey {
  static const String username = 'username';
  static const String isDarkMode = 'isDarkMode';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String defaultOrganizationId = 'default_organization_id';
  // ...
}

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  late SharedPreferences _prefs;

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  /// Gọi phương thức này trong main() trước khi runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===========================
  // Ví dụ các getter & setter
  // ===========================

  // String
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  // Bool
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  // Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  // Double
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  // List<String>
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Xóa một key
  Future<bool> remove(String key) => _prefs.remove(key);

  // Xóa toàn bộ dữ liệu
  Future<bool> clear() => _prefs.clear();
}
