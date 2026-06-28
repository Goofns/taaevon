import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/achievements/domain/achievement.dart';

AchievementSnapshot _snap({
  int totalCompletions = 0,
  int streak = 0,
  int polyglot = 0,
  int tessellation = 0,
  int vector = 0,
}) =>
    AchievementSnapshot(
      totalCompletions: totalCompletions,
      streak: streak,
      polyglot: polyglot,
      tessellation: tessellation,
      vector: vector,
    );

Achievement _byId(String id) =>
    AchievementCatalog.all.firstWhere((a) => a.id == id);

void main() {
  group('AchievementSnapshot.value', () {
    test('maps each metric to its field', () {
      final s = _snap(
        totalCompletions: 1,
        streak: 2,
        polyglot: 3,
        tessellation: 4,
        vector: 5,
      );
      expect(s.value(AchievementMetric.totalCompletions), 1);
      expect(s.value(AchievementMetric.streak), 2);
      expect(s.value(AchievementMetric.polyglot), 3);
      expect(s.value(AchievementMetric.tessellation), 4);
      expect(s.value(AchievementMetric.vector), 5);
    });
  });

  group('AchievementCatalog.isUnlocked', () {
    test('unlocks exactly at the threshold', () {
      expect(AchievementCatalog.isUnlocked(_byId('first'), _snap()), isFalse);
      expect(
        AchievementCatalog.isUnlocked(_byId('first'), _snap(totalCompletions: 1)),
        isTrue,
      );
    });

    test('stays locked one below the threshold', () {
      expect(
        AchievementCatalog.isUnlocked(
            _byId('dedicated'), _snap(totalCompletions: 24)),
        isFalse,
      );
      expect(
        AchievementCatalog.isUnlocked(
            _byId('dedicated'), _snap(totalCompletions: 25)),
        isTrue,
      );
    });

    test('streak and per-activity metrics are independent', () {
      // A big total does not unlock streak- or activity-gated achievements.
      final s = _snap(totalCompletions: 100);
      expect(AchievementCatalog.isUnlocked(_byId('on_a_roll'), s), isFalse);
      expect(AchievementCatalog.isUnlocked(_byId('polyglot'), s), isFalse);
      expect(AchievementCatalog.isUnlocked(_byId('navigator'), s), isFalse);
    });

    test('each per-activity metric only counts its own activity', () {
      final s = _snap(polyglot: 10);
      expect(AchievementCatalog.isUnlocked(_byId('polyglot'), s), isTrue);
      expect(AchievementCatalog.isUnlocked(_byId('tessellator'), s), isFalse);
      expect(AchievementCatalog.isUnlocked(_byId('navigator'), s), isFalse);
    });
  });

  group('AchievementCatalog.unlockedCount / unlockedIds', () {
    test('a fresh snapshot unlocks nothing', () {
      expect(AchievementCatalog.unlockedCount(_snap()), 0);
      expect(AchievementCatalog.unlockedIds(_snap()), isEmpty);
    });

    test('total=5 unlocks first and warming_up only', () {
      final s = _snap(totalCompletions: 5);
      expect(AchievementCatalog.unlockedIds(s), {'first', 'warming_up'});
      expect(AchievementCatalog.unlockedCount(s), 2);
    });

    test('a maxed-out snapshot unlocks the whole catalogue', () {
      final s = _snap(
        totalCompletions: 100,
        streak: 30,
        polyglot: 10,
        tessellation: 10,
        vector: 10,
      );
      expect(
        AchievementCatalog.unlockedCount(s),
        AchievementCatalog.all.length,
      );
    });
  });

  group('catalogue integrity', () {
    test('achievement ids are unique', () {
      final ids = AchievementCatalog.all.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every threshold is positive', () {
      for (final a in AchievementCatalog.all) {
        expect(a.threshold, greaterThan(0), reason: a.id);
      }
    });
  });
}
