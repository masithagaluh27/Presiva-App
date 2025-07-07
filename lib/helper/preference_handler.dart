import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static SharedPreferences? _preferences;

  static const String _authTokenKey = 'auth_token';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void _ensureInitialized() {
    if (_preferences == null) {
      throw Exception("PreferenceHandler not initialized. Call init() first.");
    }
  }

  static Future<bool> saveAuthToken(String token) async {
    _ensureInitialized();
    return await _preferences!.setString(_authTokenKey, token);
  }

  static String? getAuthToken() {
    _ensureInitialized();
    return _preferences!.getString(_authTokenKey);
  }

  static Future<bool> removeAuthToken() async {
    _ensureInitialized();
    return await _preferences!.remove(_authTokenKey);
  }

  static Future<bool> saveBool(String key, bool value) async {
    _ensureInitialized();
    return await _preferences!.setBool(key, value);
  }

  static bool? getBool(String key) {
    _ensureInitialized();
    return _preferences!.getBool(key);
  }

  static Future<bool> saveString(String key, String value) async {
    _ensureInitialized();
    return await _preferences!.setString(key, value);
  }

  static String? getString(String key) {
    _ensureInitialized();
    return _preferences!.getString(key);
  }

  static Future<bool> clearKey(String key) async {
    _ensureInitialized();
    return await _preferences!.remove(key);
  }

  static Future<bool> clearAll() async {
    _ensureInitialized();
    return await _preferences!.clear();
  }
}
