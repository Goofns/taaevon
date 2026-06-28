import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/domain/spaced_repetition.dart';

void main() {
  group('SpacedRepetition (SM-2)', () {
    test('ease deltas from E=2.5 match the SM-2 reference', () {
      // q -> expected new ease (verified via Python oracle)
      const expected = {
        0: 1.70,
        1: 1.96,
        2: 2.18,
        3: 2.36,
        4: 2.50,
        5: 2.60,
      };
      expected.forEach((q, ease) {
        final r = SpacedRepetition.review(
          easeFactor: 2.5,
          intervalDays: 0,
          repetitions: 0,
          quality: q,
        );
        expect(r.easeFactor, closeTo(ease, 1e-9), reason: 'q=$q');
      });
    });

    test('four perfect reviews schedule 1, 6, 17, 49 days', () {
      var ease = 2.5;
      var interval = 0;
      var reps = 0;
      final intervals = <int>[];
      for (var i = 0; i < 4; i++) {
        final r = SpacedRepetition.review(
          easeFactor: ease,
          intervalDays: interval,
          repetitions: reps,
          quality: 5,
        );
        ease = r.easeFactor;
        interval = r.intervalDays;
        reps = r.repetitions;
        intervals.add(interval);
      }
      expect(intervals, [1, 6, 17, 49]);
      expect(reps, 4);
      expect(ease, closeTo(2.90, 1e-9));
    });

    test('a lapse (q<3) resets interval and repetitions but adjusts ease', () {
      final r = SpacedRepetition.review(
        easeFactor: 2.5,
        intervalDays: 49,
        repetitions: 4,
        quality: 1,
      );
      expect(r.intervalDays, 1);
      expect(r.repetitions, 0);
      expect(r.easeFactor, closeTo(1.96, 1e-9));
    });

    test('ease never drops below the 1.3 floor', () {
      var ease = 1.3;
      for (var i = 0; i < 10; i++) {
        ease = SpacedRepetition.review(
          easeFactor: ease,
          intervalDays: 0,
          repetitions: 0,
          quality: 0,
        ).easeFactor;
      }
      expect(ease, 1.3);
    });
  });
}
