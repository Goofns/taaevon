import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the per-word SM-2 schedules as a JSON object keyed by word id.
abstract class ReviewStore {
  Future<Map<String, dynamic>> load();
  Future<void> save(Map<String, dynamic> schedules);
}

class InMemoryReviewStore implements ReviewStore {
  Map<String, dynamic> _data = const {};

  @override
  Future<Map<String, dynamic>> load() async => Map<String, dynamic>.of(_data);

  @override
  Future<void> save(Map<String, dynamic> schedules) async =>
      _data = Map<String, dynamic>.of(schedules);
}

class SharedPrefsReviewStore implements ReviewStore {
  static const String _key = 'taaevon.review.schedules';

  @override
  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Corrupt / partially-written value — fall through, clear it, start clean.
    }
    await prefs.remove(_key);
    return <String, dynamic>{};
  }

  @override
  Future<void> save(Map<String, dynamic> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(schedules));
  }
}
