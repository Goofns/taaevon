import 'dart:math';

import 'math_problem_template.dart';

/// In-memory bank of problem templates spanning arithmetic through calculus.
/// All answers are integers so they can be checked against a single input and,
/// when interlocked, have their small operands rendered as number-words.
class MathProblemBank {
  MathProblemBank() : _templates = _build();

  final List<MathProblemTemplate> _templates;

  List<MathProblemTemplate> forTier(int tier) =>
      _templates.where((t) => t.tier == tier).toList(growable: false);

  /// Maps a continuous band (1.0–3.99) to a tier and returns a random template.
  MathProblemTemplate forBand(double band, Random rng) {
    final tier = band < 2.0 ? 1 : (band < 3.0 ? 2 : 3);
    final pool = forTier(tier);
    return pool[rng.nextInt(pool.length)];
  }

  static List<MathProblemTemplate> _build() => [
        MathProblemTemplate(
          id: 't1-add',
          domain: 'Arithmetic',
          tier: 1,
          promptTemplate: '{a} + {b} = ?',
          variableNames: ['a', 'b'],
          computeAnswer: (b) => b['a']! + b['b']!,
        ),
        MathProblemTemplate(
          id: 't1-mul',
          domain: 'Arithmetic',
          tier: 1,
          promptTemplate: '{a} × {b} = ?',
          variableNames: ['a', 'b'],
          computeAnswer: (b) => b['a']! * b['b']!,
        ),
        MathProblemTemplate(
          id: 't2-eval',
          domain: 'Algebra',
          tier: 2,
          promptTemplate: 'Evaluate  {a} × {b} + {c}.',
          variableNames: ['a', 'b', 'c'],
          computeAnswer: (b) => b['a']! * b['b']! + b['c']!,
        ),
        MathProblemTemplate(
          id: 't2-solve',
          domain: 'Algebra',
          tier: 2,
          promptTemplate: 'Solve  {a}·x = {a}·{b}  for x.',
          variableNames: ['a', 'b'],
          computeAnswer: (b) => b['b']!,
        ),
        MathProblemTemplate(
          id: 't3-deriv',
          domain: 'Calculus',
          tier: 3,
          promptTemplate: 'f(x) = x².  Using f′(x) = 2x, compute f′({x0}).',
          variableNames: ['x0'],
          computeAnswer: (b) => 2 * b['x0']!,
        ),
        MathProblemTemplate(
          id: 't3-int',
          domain: 'Calculus',
          tier: 3,
          promptTemplate: 'Compute the definite integral  ∫₀^{x0} 2x dx.',
          variableNames: ['x0'],
          computeAnswer: (b) => b['x0']! * b['x0']!,
        ),
      ];
}
