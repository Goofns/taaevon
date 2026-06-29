import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taaevon/features/progress/data/progress_store.dart';
import 'package:taaevon/features/review/data/review_store.dart';
import 'package:taaevon/features/settings/data/settings_store.dart';
import 'package:taaevon/features/streak/data/streak_store.dart';

/// Regression tests for the runtime crash where a corrupt / partially-written
/// shared_preferences value made the stores throw on load — which (for the
/// settings store) wedged the whole app on its loading spinner forever, since
/// `SettingsCubit.hydrate()` never reached its `hydrated: true` emit.
///
/// These could not be caught by the existing tests because those use the
/// in-memory stores, which never call `json.decode`. We exercise the real
/// SharedPrefs stores against a mocked store seeded with bad data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefs stores survive corrupt values without throwing', () {
    test('SettingsStore.load returns null on truncated JSON', () async {
      SharedPreferences.setMockInitialValues(
          {'taaevon.settings': '{"dailyGoal":5'});
      expect(await SharedPrefsSettingsStore().load(), isNull);
    });

    test('SettingsStore.load returns null on non-object JSON', () async {
      SharedPreferences.setMockInitialValues({'taaevon.settings': '5'});
      expect(await SharedPrefsSettingsStore().load(), isNull);
    });

    test('StreakStore.load returns null on a JSON array', () async {
      SharedPreferences.setMockInitialValues({'taaevon.streak': '[1,2,3]'});
      expect(await SharedPrefsStreakStore().load(), isNull);
    });

    test('ReviewStore.load returns empty map on garbage', () async {
      SharedPreferences.setMockInitialValues(
        {'taaevon.review.schedules': 'not json at all'},
      );
      expect(await SharedPrefsReviewStore().load(), isEmpty);
    });

    test('ProgressStore.load returns empty map on truncated JSON', () async {
      SharedPreferences.setMockInitialValues(
        {'taaevon.progress.completions': '{"polyglot":'},
      );
      expect(await SharedPrefsProgressStore().load(), isEmpty);
    });

    test('ProgressStore.load returns empty when counts are not numbers',
        () async {
      SharedPreferences.setMockInitialValues(
        {'taaevon.progress.completions': '{"polyglot":"oops"}'},
      );
      expect(await SharedPrefsProgressStore().load(), isEmpty);
    });

    test('a corrupt value is cleared so the next launch is clean', () async {
      SharedPreferences.setMockInitialValues({'taaevon.settings': '{bad'});
      await SharedPrefsSettingsStore().load();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('taaevon.settings'), isFalse);
    });

    test('valid stored data still loads correctly', () async {
      SharedPreferences.setMockInitialValues(
        {'taaevon.settings': '{"dailyGoal":7,"reduceMotion":true}'},
      );
      final m = await SharedPrefsSettingsStore().load();
      expect(m, isNotNull);
      expect(m!['dailyGoal'], 7);
      expect(m['reduceMotion'], true);
    });
  });
}
