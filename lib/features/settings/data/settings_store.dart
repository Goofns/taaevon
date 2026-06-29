import '../../../core/data/json_prefs.dart';

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
  Future<Map<String, dynamic>?> load() => loadJsonMap(_key);

  @override
  Future<void> save(Map<String, dynamic> data) => saveJsonMap(_key, data);
}
