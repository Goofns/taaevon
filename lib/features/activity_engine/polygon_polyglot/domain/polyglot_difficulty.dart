import '../../../sync_engine/dynamic_difficulty_calibrator.dart';

/// Difficulty parameters for a Polygon Polyglot session (PRD §9.2).
/// The polygon has [polygonSides] vertices; each round offers [optionCount]
/// tiles.
class PolyglotDifficulty {
  const PolyglotDifficulty({
    required this.polygonSides,
    required this.optionCount,
  });

  final int polygonSides;
  final int optionCount;

  factory PolyglotDifficulty.forCefr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a0:
      case CefrLevel.a1:
        return const PolyglotDifficulty(
          polygonSides: 4,
          optionCount: 4,
        );
      case CefrLevel.a2:
      case CefrLevel.b1:
        return const PolyglotDifficulty(
          polygonSides: 5,
          optionCount: 6,
        );
      case CefrLevel.b2:
      case CefrLevel.c1:
        return const PolyglotDifficulty(
          polygonSides: 7,
          optionCount: 8,
        );
      case CefrLevel.c2:
        return const PolyglotDifficulty(
          polygonSides: 9,
          optionCount: 10,
        );
    }
  }
}
