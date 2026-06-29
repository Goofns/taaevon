import '../../../core/data/json_prefs.dart';

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
  Future<Map<String, dynamic>> load() async =>
      (await loadJsonMap(_key)) ?? <String, dynamic>{};

  @override
  Future<void> save(Map<String, dynamic> schedules) =>
      saveJsonMap(_key, schedules);
}
