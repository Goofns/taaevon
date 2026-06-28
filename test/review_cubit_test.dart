import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/review/bloc/review_cubit.dart';
import 'package:taaevon/features/review/data/review_store.dart';

class _StubLexiconRepo implements LexiconRepository {
  _StubLexiconRepo(this._entries);
  final List<LexiconEntry> _entries;

  @override
  Future<List<LexiconEntry>> all() async => _entries;

  @override
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async =>
      _entries.where((e) => e.targetLanguage == targetLanguage).toList();
}

LexiconEntry _word(String id) => LexiconEntry(
      wordId: id,
      sourceLanguage: 'en',
      targetLanguage: 'es',
      baseTerm: 'b-$id',
      translatedTerm: 't-$id',
      lexicalCategory: 'everyday',
      syllableCount: 2,
      mathExtractedValue: 2,
    );

void main() {
  group('ReviewCubit', () {
    test('starts a session over due (new) words', () async {
      final cubit = ReviewCubit(
        lexicon: _StubLexiconRepo([_word('1'), _word('2')]),
        store: InMemoryReviewStore(),
        random: Random(1),
        clock: () => DateTime(2026, 6, 27),
      );
      await cubit.start('es');
      expect(cubit.state, isA<ReviewInProgress>());
      expect((cubit.state as ReviewInProgress).total, 2);
    });

    test('grading every word completes the session and persists', () async {
      final store = InMemoryReviewStore();
      final cubit = ReviewCubit(
        lexicon: _StubLexiconRepo([_word('1'), _word('2')]),
        store: store,
        random: Random(1),
        clock: () => DateTime(2026, 6, 27),
      );
      await cubit.start('es');

      cubit
        ..reveal()
        ..grade(4);
      cubit
        ..reveal()
        ..grade(4);

      expect(cubit.state, isA<ReviewComplete>());
      await Future<void>.delayed(Duration.zero);
      final saved = await store.load();
      expect(saved.length, 2); // both words now have schedules
    });

    test('reports empty when nothing is due', () async {
      final store = InMemoryReviewStore();
      await store.save({
        '1': {
          'ease': 2.5,
          'intervalDays': 30,
          'repetitions': 5,
          'dueDate': '2026-12-31',
        },
      });
      final cubit = ReviewCubit(
        lexicon: _StubLexiconRepo([_word('1')]),
        store: store,
        clock: () => DateTime(2026, 6, 27),
      );
      await cubit.start('es');
      expect(cubit.state, isA<ReviewEmpty>());
    });
  });
}
