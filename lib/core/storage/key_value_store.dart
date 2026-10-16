import 'package:shared_preferences/shared_preferences.dart';

/// Minimal string key/value storage used by local data sources.
///
/// Hiding SharedPreferences behind this interface keeps local data sources
/// testable with a simple in-memory fake.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesStore implements KeyValueStore {
  const SharedPreferencesStore(this._prefs);

  final SharedPreferencesWithCache _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
