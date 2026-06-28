import 'package:equatable/equatable.dart';

/// A consecutive-day practice streak.
class Streak extends Equatable {
  const Streak({
    this.count = 0,
    this.lastActiveDate,
    this.hydrated = false,
  });

  final int count;

  /// 'YYYY-MM-DD' of the last day an activity was completed, or null.
  final String? lastActiveDate;

  /// Transient (not persisted): true once loaded from the store.
  final bool hydrated;

  Streak copyWith({int? count, String? lastActiveDate, bool? hydrated}) =>
      Streak(
        count: count ?? this.count,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        hydrated: hydrated ?? this.hydrated,
      );

  Map<String, dynamic> toMap() =>
      {'count': count, 'lastActiveDate': lastActiveDate};

  factory Streak.fromMap(Map<String, dynamic> m) => Streak(
        count: (m['count'] as num?)?.toInt() ?? 0,
        lastActiveDate: m['lastActiveDate'] as String?,
      );

  @override
  List<Object?> get props => [count, lastActiveDate, hydrated];
}

/// Pure streak arithmetic — kept free of Flutter and the clock so it is fully
/// unit-testable.
abstract class StreakCalculator {
  /// Local calendar day as 'YYYY-MM-DD'.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// The streak after recording activity at [now]:
  ///  * same day as last  → unchanged
  ///  * exactly the next day → +1
  ///  * a gap, or first ever → reset to 1
  static Streak recordActivity(Streak current, DateTime now) {
    final today = dateKey(now);
    if (current.lastActiveDate == today) return current;
    final yesterday = dateKey(now.subtract(const Duration(days: 1)));
    final count = current.lastActiveDate == yesterday ? current.count + 1 : 1;
    return current.copyWith(count: count, lastActiveDate: today);
  }
}
