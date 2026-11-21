import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over persistent key-value storage.
abstract interface class KeyValueStorage {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

/// SharedPreferences-backed implementation of [KeyValueStorage].
class SharedPreferencesStorage implements KeyValueStorage {
  SharedPreferences? _cached;

  Future<SharedPreferences> _getPrefs() async {
    return _cached ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString(key, value);
  }
}
