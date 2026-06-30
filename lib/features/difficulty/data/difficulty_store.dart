import '../../../core/data/json_prefs.dart';

/// Persistence boundary for the difficulty profile (the learner's current math
/// band). Deals in a plain map so it has no dependency on the cubit's state.
abstract class DifficultyStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

class InMemoryDifficultyStore implements DifficultyStore {
  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> load() async =>
      _data == null ? null : Map<String, dynamic>.of(_data!);

  @override
  Future<void> save(Map<String, dynamic> data) async =>
      _data = Map<String, dynamic>.of(data);
}

class SharedPrefsDifficultyStore implements DifficultyStore {
  static const String _key = 'taaevon.difficulty';

  @override
  Future<Map<String, dynamic>?> load() => loadJsonMap(_key);

  @override
  Future<void> save(Map<String, dynamic> data) => saveJsonMap(_key, data);
}
