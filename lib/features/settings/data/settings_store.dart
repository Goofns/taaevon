import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for user settings. Deals in a plain map so it has no
/// dependency on the cubit's state class (the cubit owns serialisation).
abstract class SettingsStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

class InMemorySettingsStore implements SettingsStore {
  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> load() async =>
      _data == null ? null : Map<String, dynamic>.of(_data!);

  @override
  Future<void> save(Map<String, dynamic> data) async =>
      _data = Map<String, dynamic>.of(data);
}

class SharedPrefsSettingsStore implements SettingsStore {
  static const String _key = 'taaevon.settings';

  @override
  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Corrupt / partially-written value — fall through, clear it, start clean.
    }
    await prefs.remove(_key);
    return null;
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(data));
  }
}
