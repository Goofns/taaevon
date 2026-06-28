import 'dart:math' as math;

/// CEFR proficiency levels (A0 = absolute zero exposure).
enum CefrLevel { a0, a1, a2, b1, b2, c1, c2 }

/// How the math and language tracks interlock for a given user (PRD §10.2).
enum InjectionMode {
  /// Equations use target-language number-words / instructions.
  mathInstructsLanguage,

  /// Language word-data (syllables, lengths) seeds math variable values.
  languageSeedsMath,

  /// No injection — tracks run independently.
  parallelIndependent,

  /// Both directions simultaneously (e.g. post-grad math in beginner script).
  fullInterlock,
}

/// Output of a difficulty calibration step.
class DdcResult {
  const DdcResult({
    required this.calibratedLevel,
    required this.performanceScore,
  });

  final double calibratedLevel;
  final double performanceScore;
}

/// Dynamic Difficulty Calibration engine (PRD §10.2). Pure functions over
/// telemetry — independent pipelines for math and language combine only at the
/// injection-mode decision.
abstract class DynamicDifficultyCalibrator {
  /// Difficulty step function.
  ///
  /// performance = 0.7·accuracy + 0.3·min(target/actual responseTime, 1.0)
  /// score > 0.85 steps up (+0.1); score < 0.60 steps down (−0.15); the
  /// 0.60–0.85 band is the optimal zone and holds. Result is clamped to the
  /// active band.
  static DdcResult calibrate({
    required double currentLevel,
    required double accuracy,
    required int avgResponseMs,
    required int targetResponseMs,
    required double bandFloor,
    required double bandCeiling,
  }) {
    final efficiency = targetResponseMs / avgResponseMs;
    final score = 0.7 * accuracy + 0.3 * math.min(efficiency, 1.0);

    var next = currentLevel;
    if (score > 0.85) {
      next += 0.1;
    } else if (score < 0.60) {
      next -= 0.15;
    }
    final calibrated = next.clamp(bandFloor, bandCeiling).toDouble();
    return DdcResult(calibratedLevel: calibrated, performanceScore: score);
  }

  /// Cross-domain injection mode from the math band (1.0–3.99, where 1.x =
  /// Foundational, 2.x = Intermediate, 3.x = Advanced) and CEFR level.
  static InjectionMode decideInjectionMode(double mathBand, CefrLevel cefr) {
    final advanced = mathBand >= 3.0; // Band 3A+
    final advancedUpper = mathBand >= 3.33; // Band 3B–3C
    final intermediate = mathBand >= 2.0 && mathBand < 3.0; // 2A–2C
    final foundational = mathBand < 1.66; // 1A–1B

    final beginner = cefr == CefrLevel.a0 || cefr == CefrLevel.a1;
    final elemInter = cefr == CefrLevel.a2 || cefr == CefrLevel.b1;
    final upper = cefr.index >= CefrLevel.b2.index; // B2–C2
    final b1Plus = cefr.index >= CefrLevel.b1.index; // B1+

    if (advanced && beginner) return InjectionMode.fullInterlock;
    if (advancedUpper && b1Plus) return InjectionMode.fullInterlock;
    if (foundational && upper) return InjectionMode.languageSeedsMath;
    if (intermediate && elemInter) return InjectionMode.mathInstructsLanguage;
    return InjectionMode.parallelIndependent;
  }
}
