import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Shared guarded JSON-object persistence over [SharedPreferences], used by the
/// settings / streak / review / progress stores.
///
/// Loads the value at [key]. Returns null when it is absent or empty, or when it
/// is corrupt / not a JSON object — in which case the bad value is removed so the
/// next launch starts clean (this is what stops a partial write from wedging the
/// app on its loading spinner).
Future<Map<String, dynamic>?> loadJsonMap(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(key);
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = json.decode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {
    // Corrupt / partially-written value — fall through, clear it, start clean.
  }
  await prefs.remove(key);
  return null;
}

/// Persists [data] as a JSON object at [key].
Future<void> saveJsonMap(String key, Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, json.encode(data));
}
