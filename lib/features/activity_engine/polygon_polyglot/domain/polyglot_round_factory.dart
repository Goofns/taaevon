import 'dart:math';

import '../../../language/domain/lexicon_entry.dart';
import 'polyglot_round.dart';

/// Builds a [PolyglotRound] for a [target] word, drawing unique distractors
/// from [pool] (same target language). Distractors are de-duplicated by their
/// displayed text so two tiles never show the same word.
class PolyglotRoundFactory {
  PolyglotRoundFactory({Random? random}) : _rng = random ?? Random();

  final Random _rng;
  Random get random => _rng;

  PolyglotRound build({
    required LexiconEntry target,
    required List<LexiconEntry> pool,
    required int optionCount,
  }) {
    final distractors = pool.where((e) => e.wordId != target.wordId).toList()
      ..shuffle(_rng);

    final used = <String>{target.translatedTerm};
    final chosen = <LexiconEntry>[];
    for (final d in distractors) {
      if (chosen.length >= optionCount - 1) break;
      if (used.add(d.translatedTerm)) chosen.add(d);
    }

    final options = <PolyglotOption>[
      PolyglotOption(
        text: target.translatedTerm,
        romanization: target.romanization,
        isCorrect: true,
      ),
      for (final d in chosen)
        PolyglotOption(
          text: d.translatedTerm,
          romanization: d.romanization,
          isCorrect: false,
        ),
    ]..shuffle(_rng);

    return PolyglotRound(
      promptTerm: target.baseTerm,
      targetLanguage: target.targetLanguage,
      options: options,
      correctText: target.translatedTerm,
    );
  }
}
