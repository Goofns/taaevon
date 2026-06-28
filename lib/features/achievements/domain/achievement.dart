import 'package:equatable/equatable.dart';

/// Which progress metric an achievement is unlocked by.
enum AchievementMetric { totalCompletions, streak, polyglot, tessellation, vector }

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.threshold,
  });

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int threshold;

  @override
  List<Object?> get props => [id];
}

/// A read-only snapshot of the values achievements are evaluated against. The
/// presentation layer builds this from the progress and streak cubits, so
/// achievements need no storage of their own — they are derived state.
class AchievementSnapshot {
  const AchievementSnapshot({
    required this.totalCompletions,
    required this.streak,
    required this.polyglot,
    required this.tessellation,
    required this.vector,
  });

  final int totalCompletions;
  final int streak;
  final int polyglot;
  final int tessellation;
  final int vector;

  int value(AchievementMetric m) => switch (m) {
        AchievementMetric.totalCompletions => totalCompletions,
        AchievementMetric.streak => streak,
        AchievementMetric.polyglot => polyglot,
        AchievementMetric.tessellation => tessellation,
        AchievementMetric.vector => vector,
      };
}

/// The fixed catalogue of achievements plus pure unlock evaluation.
abstract class AchievementCatalog {
  static const List<Achievement> all = [
    Achievement(
      id: 'first',
      title: 'First Steps',
      description: 'Complete your first activity.',
      metric: AchievementMetric.totalCompletions,
      threshold: 1,
    ),
    Achievement(
      id: 'warming_up',
      title: 'Warming Up',
      description: 'Complete 5 activities.',
      metric: AchievementMetric.totalCompletions,
      threshold: 5,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated',
      description: 'Complete 25 activities.',
      metric: AchievementMetric.totalCompletions,
      threshold: 25,
    ),
    Achievement(
      id: 'centurion',
      title: 'Centurion',
      description: 'Complete 100 activities.',
      metric: AchievementMetric.totalCompletions,
      threshold: 100,
    ),
    Achievement(
      id: 'on_a_roll',
      title: 'On a Roll',
      description: 'Reach a 3-day streak.',
      metric: AchievementMetric.streak,
      threshold: 3,
    ),
    Achievement(
      id: 'week_strong',
      title: 'Week Strong',
      description: 'Reach a 7-day streak.',
      metric: AchievementMetric.streak,
      threshold: 7,
    ),
    Achievement(
      id: 'unstoppable',
      title: 'Unstoppable',
      description: 'Reach a 30-day streak.',
      metric: AchievementMetric.streak,
      threshold: 30,
    ),
    Achievement(
      id: 'polyglot',
      title: 'Polyglot',
      description: 'Solve 10 Polygon Polyglot polygons.',
      metric: AchievementMetric.polyglot,
      threshold: 10,
    ),
    Achievement(
      id: 'tessellator',
      title: 'Tessellator',
      description: 'Complete 10 tessellations.',
      metric: AchievementMetric.tessellation,
      threshold: 10,
    ),
    Achievement(
      id: 'navigator',
      title: 'Navigator',
      description: 'Reach 10 vector targets.',
      metric: AchievementMetric.vector,
      threshold: 10,
    ),
  ];

  static bool isUnlocked(Achievement a, AchievementSnapshot s) =>
      s.value(a.metric) >= a.threshold;

  static Set<String> unlockedIds(AchievementSnapshot s) =>
      {for (final a in all) if (isUnlocked(a, s)) a.id};

  static int unlockedCount(AchievementSnapshot s) =>
      all.where((a) => isUnlocked(a, s)).length;
}
