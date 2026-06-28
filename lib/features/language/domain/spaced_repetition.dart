/// Result of an SM-2 review step.
class Sm2Review {
  const Sm2Review({
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
  });

  final double easeFactor;
  final int intervalDays;
  final int repetitions;
}

/// SuperMemo-2 spaced-repetition scheduler (PRD §8.4).
///
/// Verified against the Python oracle: ease deltas from E=2.5 are
/// q5:+0.10, q4:0.00, q3:-0.14, q2:-0.32, q1:-0.54, q0:-0.80; four perfect
/// reviews yield intervals 1, 6, 17, 49 days.
abstract class SpacedRepetition {
  static const double minEase = 1.3;

  static double _updateEase(double ease, int quality) {
    final q = quality.toDouble();
    final next = ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    return next < minEase ? minEase : next;
  }

  /// Apply one review. [quality] is recall quality on the 0–5 scale.
  static Sm2Review review({
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
    required int quality,
  }) {
    assert(quality >= 0 && quality <= 5, 'quality must be 0..5');
    final newEase = _updateEase(easeFactor, quality);

    // A lapse (q < 3) resets the schedule but still adjusts ease.
    if (quality < 3) {
      return Sm2Review(easeFactor: newEase, intervalDays: 1, repetitions: 0);
    }

    final newReps = repetitions + 1;
    final int interval;
    if (newReps == 1) {
      interval = 1;
    } else if (newReps == 2) {
      interval = 6;
    } else {
      interval = (intervalDays * newEase).round();
    }
    return Sm2Review(
      easeFactor: newEase,
      intervalDays: interval,
      repetitions: newReps,
    );
  }

  /// Convenience for a brand-new card's first review.
  static Sm2Review firstReview(int quality) => review(
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        quality: quality,
      );
}
