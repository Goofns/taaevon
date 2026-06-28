import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/sync_engine/dynamic_difficulty_calibrator.dart';
import 'package:taaevon/features/sync_engine/interlocking_progression.dart';

LexiconEntry _numeral(String script, String roman, int value) => LexiconEntry(
      wordId: 'ja-$roman',
      sourceLanguage: 'en',
      targetLanguage: 'ja',
      baseTerm: roman,
      translatedTerm: script,
      lexicalCategory: 'everyday',
      partOfSpeech: 'numeral',
      syllableCount: 1,
      mathExtractedValue: value,
      romanization: roman,
    );

void main() {
  const engine = InterlockingProgression();

  // Japanese numerals (the PRD §10.3 vocabulary set).
  final jaNumerals = [
    _numeral('いち', 'ichi', 1),
    _numeral('に', 'ni', 2),
    _numeral('さん', 'san', 3),
  ];

  group('InterlockingProgression.inject', () {
    test('full interlock renders x0 = 3 as さん with a glossary entry', () {
      final result = engine.inject(
        template: 'Prove f(x)=x^2 is continuous at x0 = {x0} (epsilon-delta).',
        bindings: {'x0': 3},
        targetVocab: jaNumerals,
        mode: InjectionMode.fullInterlock,
      );

      expect(result.prompt, contains('さん'));
      expect(result.prompt, isNot(contains('x0 = 3')));
      expect(result.glossary, hasLength(1));
      expect(result.glossary.single.script, 'さん');
      expect(result.glossary.single.value, 3);
      expect(result.glossary.single.gloss, 'さん (san) = 3');
    });

    test('parallel mode leaves numbers as digits and adds no glossary', () {
      final result = engine.inject(
        template: 'Evaluate f({x0}).',
        bindings: {'x0': 3},
        targetVocab: jaNumerals,
        mode: InjectionMode.parallelIndependent,
      );

      expect(result.prompt, 'Evaluate f(3).');
      expect(result.glossary, isEmpty);
    });

    test('a value with no matching numeral falls back to the digit', () {
      final result = engine.inject(
        template: 'x = {x}',
        bindings: {'x': 7}, // no numeral for 7 in the vocab
        targetVocab: jaNumerals,
        mode: InjectionMode.fullInterlock,
      );
      expect(result.prompt, 'x = 7');
      expect(result.glossary, isEmpty);
    });
  });

  group('InterlockingProgression.seedBindingsFromVocab', () {
    test('derives math variable values from syllable counts', () {
      final vocab = [
        LexiconEntry(
          wordId: 'w1',
          sourceLanguage: 'en',
          targetLanguage: 'ja',
          baseTerm: 'thank you',
          translatedTerm: 'ありがとう',
          lexicalCategory: 'everyday',
          syllableCount: 5,
          mathExtractedValue: 5,
        ),
        LexiconEntry(
          wordId: 'w2',
          sourceLanguage: 'en',
          targetLanguage: 'ja',
          baseTerm: 'water',
          translatedTerm: 'みず',
          lexicalCategory: 'everyday',
          syllableCount: 2,
          mathExtractedValue: 2,
        ),
      ];
      final bindings = engine.seedBindingsFromVocab(['a', 'b', 'c'], vocab);
      expect(bindings, {'a': 5, 'b': 2, 'c': 5}); // wraps around
    });
  });
}
