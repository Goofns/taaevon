import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/review/domain/review_schedule.dart';

void main() {
  group('ReviewScheduler', () {
    test('a never-reviewed word is always due', () {
      expect(ReviewScheduler.isDue(null, DateTime(2026, 6, 27)), isTrue);
    });

    test('isDue compares the due date to today', () {
      final now = DateTime(2026, 6, 27);
      expect(ReviewScheduler.isDue(
          const ReviewSchedule(dueDate: '2026-06-20'), now), isTrue);
      expect(ReviewScheduler.isDue(
          const ReviewSchedule(dueDate: '2026-06-27'), now), isTrue);
      expect(ReviewScheduler.isDue(
          const ReviewSchedule(dueDate: '2026-07-01'), now), isFalse);
    });

    test('grading a new word Good schedules it one day out at rep 1', () {
      final s = ReviewScheduler.grade(null, 4, DateTime(2026, 6, 27));
      expect(s.repetitions, 1);
      expect(s.intervalDays, 1);
      expect(s.dueDate, '2026-06-28');
      expect(s.ease, closeTo(2.5, 1e-9)); // q=4 keeps ease unchanged
    });

    test('grading Again resets the interval to one day', () {
      const current = ReviewSchedule(
        ease: 2.6,
        intervalDays: 10,
        repetitions: 3,
        dueDate: '2026-06-27',
      );
      final s = ReviewScheduler.grade(current, 1, DateTime(2026, 6, 27));
      expect(s.repetitions, 0);
      expect(s.intervalDays, 1);
      expect(s.dueDate, '2026-06-28');
    });

    test('toMap/fromMap round-trips', () {
      const s = ReviewSchedule(
        ease: 2.7,
        intervalDays: 6,
        repetitions: 2,
        dueDate: '2026-07-03',
      );
      expect(ReviewSchedule.fromMap(s.toMap()), s);
    });
  });
}
