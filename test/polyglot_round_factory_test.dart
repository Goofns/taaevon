import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/domain/polyglot_round_factory.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';

LexiconEntry _e(String id, String term) => LexiconEntry(
      wordId: id,
      sourceLanguage: 'en',
      targetLanguage: 'ja',
      baseTerm: 'w-$id',
      translatedTerm: term,
      lexicalCategory: 'everyday',
      syllableCount: 2,
      mathExtractedValue: 2,
      romanization: 'r-$id',
    );

void main() {
  final factory = PolyglotRoundFactory(random: Random(1));
  final pool = [
    _e('0', 'あ'),
    _e('1', 'い'),
    _e('2', 'う'),
    _e('3', 'え'),
    _e('4', 'お')
  ];

  group('PolyglotRoundFactory', () {
    test('builds exactly optionCount tiles with one correct, all unique', () {
      final r = factory.build(target: pool[0], pool: pool, optionCount: 4);
      expect(r.options.length, 4);
      expect(r.options.where((o) => o.isCorrect).length, 1);
      expect(r.correctText, 'あ');
      final texts = r.options.map((o) => o.text).toSet();
      expect(texts.length, 4, reason: 'tiles must be distinct');
      expect(texts.contains('あ'), isTrue);
    });

    test('the correct option carries the target translation', () {
      final r = factory.build(target: pool[2], pool: pool, optionCount: 4);
      final correct = r.options.firstWhere((o) => o.isCorrect);
      expect(correct.text, 'う');
      expect(r.options[r.correctIndex].isCorrect, isTrue);
    });

    test('clamps optionCount to the available unique distractors', () {
      final small = [pool[0], pool[1], pool[2]]; // target + 2 distractors
      final r = factory.build(target: small[0], pool: small, optionCount: 6);
      expect(r.options.length, 3);
      expect(r.options.where((o) => o.isCorrect).length, 1);
    });
  });
}
