import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the game and the settings between launches.
///
/// Everything stays on the device. Nothing here talks to a network.
abstract class Store {
  Map<String, Object?>? read(String key);

  Future<void> write(String key, Map<String, Object?> value);

  Future<void> remove(String key);
}

class PreferencesStore implements Store {
  PreferencesStore._(this._prefs);

  static Future<PreferencesStore> open() async =>
      PreferencesStore._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  @override
  Map<String, Object?>? read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      // Data from an older build, or a half-written value. Treated as absent
      // so the app opens on defaults instead of failing to start.
      return null;
    }
  }

  @override
  Future<void> write(String key, Map<String, Object?> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
