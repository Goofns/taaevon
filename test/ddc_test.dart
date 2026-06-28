import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/sync_engine/dynamic_difficulty_calibrator.dart';

void main() {
  group('DDC calibrate (step function)', () {
    DdcResult run(double acc, int r) => DynamicDifficultyCalibrator.calibrate(
          currentLevel: 2.0,
          accuracy: acc,
          avgResponseMs: r,
          targetResponseMs: 2000,
          bandFloor: 1.0,
          bandCeiling: 3.99,
        );

    test('high performance steps difficulty up', () {
      final r = run(0.95, 1500);
      expect(r.performanceScore, closeTo(0.965, 1e-9));
      expect(r.calibratedLevel, closeTo(2.1, 1e-9));
    });

    test('low performance steps difficulty down (faster)', () {
      final r = run(0.40, 4000);
      expect(r.performanceScore, closeTo(0.43, 1e-9));
      expect(r.calibratedLevel, closeTo(1.85, 1e-9));
    });

    test('optimal zone holds difficulty', () {
      final r = run(0.75, 2200);
      expect(r.performanceScore, closeTo(0.798, 1e-3));
      expect(r.calibratedLevel, closeTo(2.0, 1e-9));
    });

    test('clamps to band ceiling', () {
      final r = DynamicDifficultyCalibrator.calibrate(
        currentLevel: 3.95,
        accuracy: 1.0,
        avgResponseMs: 1000,
        targetResponseMs: 2000,
        bandFloor: 1.0,
        bandCeiling: 3.99,
      );
      expect(r.calibratedLevel, closeTo(3.99, 1e-9));
    });
  });

  group('DDC injection-mode decision (PRD §10.2 matrix)', () {
    test('post-grad math + A0 beginner -> full interlock', () {
      expect(
        DynamicDifficultyCalibrator.decideInjectionMode(3.66, CefrLevel.a0),
        InjectionMode.fullInterlock,
      );
    });

    test('foundational math + advanced language -> language seeds math', () {
      expect(
        DynamicDifficultyCalibrator.decideInjectionMode(1.2, CefrLevel.c1),
        InjectionMode.languageSeedsMath,
      );
    });

    test('intermediate math + A2 language -> math instructs language', () {
      expect(
        DynamicDifficultyCalibrator.decideInjectionMode(2.5, CefrLevel.a2),
        InjectionMode.mathInstructsLanguage,
      );
    });

    test('balanced levels -> parallel independent', () {
      expect(
        DynamicDifficultyCalibrator.decideInjectionMode(2.0, CefrLevel.b2),
        InjectionMode.parallelIndependent,
      );
    });
  });
}
