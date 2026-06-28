import '../../../sync_engine/dynamic_difficulty_calibrator.dart';

/// Difficulty parameters for a Polygon Polyglot session (PRD §9.2).
/// The polygon has [polygonSides] vertices; each round offers [optionCount]
/// tiles; [timeLimit] is null for the highest tier (no limit).
class PolyglotDifficulty {
  const PolyglotDifficulty({
    required this.polygonSides,
    required this.optionCount,
    this.timeLimit,
  });

  final int polygonSides;
  final int optionCount;
  final Duration? timeLimit;

  factory PolyglotDifficulty.forCefr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a0:
      case CefrLevel.a1:
        return const PolyglotDifficulty(
          polygonSides: 4,
          optionCount: 4,
          timeLimit: Duration(seconds: 20),
        );
      case CefrLevel.a2:
      case CefrLevel.b1:
        return const PolyglotDifficulty(
          polygonSides: 5,
          optionCount: 6,
          timeLimit: Duration(seconds: 15),
        );
      case CefrLevel.b2:
      case CefrLevel.c1:
        return const PolyglotDifficulty(
          polygonSides: 7,
          optionCount: 8,
          timeLimit: Duration(seconds: 10),
        );
      case CefrLevel.c2:
        return const PolyglotDifficulty(
          polygonSides: 9,
          optionCount: 10,
        );
    }
  }
}
