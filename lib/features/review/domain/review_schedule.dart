import 'package:equatable/equatable.dart';

import '../../../core/utils/date_key.dart';
import '../../language/domain/spaced_repetition.dart';

/// The persisted SM-2 schedule for a single vocabulary word.
class ReviewSchedule extends Equatable {
  const ReviewSchedule({
    this.ease = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.dueDate,
  });

  final double ease;
  final int intervalDays;
  final int repetitions;

  /// 'YYYY-MM-DD' the word is next due, or null if it has never been reviewed.
  final String? dueDate;

  Map<String, dynamic> toMap() => {
        'ease': ease,
        'intervalDays': intervalDays,
        'repetitions': repetitions,
        'dueDate': dueDate,
      };

  factory ReviewSchedule.fromMap(Map<String, dynamic> m) => ReviewSchedule(
        ease: (m['ease'] as num?)?.toDouble() ?? 2.5,
        intervalDays: (m['intervalDays'] as num?)?.toInt() ?? 0,
        repetitions: (m['repetitions'] as num?)?.toInt() ?? 0,
        dueDate: m['dueDate'] as String?,
      );

  @override
  List<Object?> get props => [ease, intervalDays, repetitions, dueDate];
}

/// Pure scheduling logic for the review queue, built on the SM-2 [SpacedRepetition]
/// scheduler. Free of Flutter and the clock so it is fully unit-testable.
abstract class ReviewScheduler {
  static String dateKey(DateTime d) => isoDateKey(d);

  /// A never-reviewed word (null schedule) is always due; otherwise it is due
  /// once its due date is on or before [now].
  static bool isDue(ReviewSchedule? schedule, DateTime now) {
    final due = schedule?.dueDate;
    if (due == null) return true;
    return due.compareTo(dateKey(now)) <= 0; // ISO dates sort chronologically
  }

  /// Apply a recall [quality] (0–5) to [schedule] and return the next one,
  /// scheduling the new due date from [now] via the SM-2 interval.
  static ReviewSchedule grade(
    ReviewSchedule? schedule,
    int quality,
    DateTime now,
  ) {
    final s = schedule ?? const ReviewSchedule();
    final r = SpacedRepetition.review(
      easeFactor: s.ease,
      intervalDays: s.intervalDays,
      repetitions: s.repetitions,
      quality: quality,
    );
    return ReviewSchedule(
      ease: r.easeFactor,
      intervalDays: r.intervalDays,
      repetitions: r.repetitions,
      dueDate: dateKey(now.add(Duration(days: r.intervalDays))),
    );
  }
}
