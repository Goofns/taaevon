import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/math/domain/math_problem_bank.dart';

void main() {
  final bank = MathProblemBank();

  group('MathProblemBank', () {
    test('arithmetic templates compute correctly', () {
      final add = bank.forTier(1).firstWhere((t) => t.id == 't1-add');
      expect(add.computeAnswer({'a': 2, 'b': 3}), 5);
      final mul = bank.forTier(1).firstWhere((t) => t.id == 't1-mul');
      expect(mul.computeAnswer({'a': 2, 'b': 3}), 6);
    });

    test('algebra "solve a·x = a·b" yields b regardless of a', () {
      final solve = bank.forTier(2).firstWhere((t) => t.id == 't2-solve');
      expect(solve.computeAnswer({'a': 7, 'b': 3}), 3);
      expect(solve.computeAnswer({'a': 2, 'b': 3}), 3);
    });

    test('calculus derivative and integral templates', () {
      final deriv = bank.forTier(3).firstWhere((t) => t.id == 't3-deriv');
      expect(deriv.computeAnswer({'x0': 3}), 6); // f'(x)=2x -> 6
      final integral = bank.forTier(3).firstWhere((t) => t.id == 't3-int');
      expect(integral.computeAnswer({'x0': 3}), 9); // ∫₀³ 2x dx = 9
    });

    test('forBand maps a continuous band to the right tier', () {
      final rng = Random(0);
      expect(bank.forBand(1.4, rng).tier, 1);
      expect(bank.forBand(2.5, rng).tier, 2);
      expect(bank.forBand(3.6, rng).tier, 3);
    });
  });
}
