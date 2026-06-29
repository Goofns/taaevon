import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/streak/domain/streak.dart';

void main() {
  group('StreakCalculator', () {
    test('dateKey formats as YYYY-MM-DD', () {
      expect(StreakCalculator.dateKey(DateTime(2026, 6, 27)), '2026-06-27');
      expect(StreakCalculator.dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('first activity starts a streak of 1', () {
      final s = StreakCalculator.recordActivity(
          const Streak(), DateTime(2026, 6, 27));
      expect(s.count, 1);
      expect(s.lastActiveDate, '2026-06-27');
    });

    test('same day leaves the streak unchanged', () {
      const current = Streak(count: 3, lastActiveDate: '2026-06-27');
      final s = StreakCalculator.recordActivity(
        current,
        DateTime(2026, 6, 27, 23, 59),
      );
      expect(s, current);
    });

    test('the next day increments the streak', () {
      const current = Streak(count: 3, lastActiveDate: '2026-06-27');
      final s = StreakCalculator.recordActivity(current, DateTime(2026, 6, 28));
      expect(s.count, 4);
      expect(s.lastActiveDate, '2026-06-28');
    });

    test('a missed day resets the streak to 1', () {
      const current = Streak(count: 9, lastActiveDate: '2026-06-25');
      final s = StreakCalculator.recordActivity(current, DateTime(2026, 6, 27));
      expect(s.count, 1);
    });

    test('a month boundary counts as consecutive', () {
      const current = Streak(count: 2, lastActiveDate: '2026-06-30');
      final s = StreakCalculator.recordActivity(current, DateTime(2026, 7, 1));
      expect(s.count, 3);
      expect(s.lastActiveDate, '2026-07-01');
    });
  });
}
