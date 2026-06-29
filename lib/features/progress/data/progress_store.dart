import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for progress data (activityId -> completion count).
/// Abstract so the cubit can be tested with an in-memory fake and swapped to a
/// different backend (SQLite/Hive) later without touching the cubit.
abstract class ProgressStore {
  Future<Map<String, int>> load();
  Future<void> save(Map<String, int> completions);
}

/// In-memory store — the default, used in tests and when persistence is not
/// wired. Nothing survives a restart.
class InMemoryProgressStore implements ProgressStore {
  Map<String, int> _data = const {};

  @override
  Future<Map<String, int>> load() async => Map<String, int>.of(_data);

  @override
  Future<void> save(Map<String, int> completions) async =>
      _data = Map<String, int>.of(completions);
}

/// Persists the completion map as a JSON string in shared preferences, so daily
/// progress survives app restarts.
class SharedPrefsProgressStore implements ProgressStore {
  static const String _key = 'taaevon.progress.completions';

  @override
  Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {
      // Corrupt value or non-numeric counts — fall through, clear, start clean.
    }
    await prefs.remove(_key);
    return <String, int>{};
  }

  @override
  Future<void> save(Map<String, int> completions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(completions));
  }
}
