import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/bloc/polyglot_bloc.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/domain/polyglot_round_factory.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/sync_engine/dynamic_difficulty_calibrator.dart';

import 'support/stub_lexicon_repo.dart';

List<LexiconEntry> _jaEntries(int n) => [
      for (var i = 0; i < n; i++)
        LexiconEntry(
          wordId: 'ja-$i',
          sourceLanguage: 'en',
          targetLanguage: 'ja',
          baseTerm: 'word$i',
          translatedTerm: '語$i',
          lexicalCategory: 'everyday',
          syllableCount: 2,
          mathExtractedValue: 2,
          romanization: 'go$i',
        ),
    ];

PolyglotBloc _makeBloc(List<LexiconEntry> entries) => PolyglotBloc(
      repository: StubLexiconRepo(entries),
      roundFactory: PolyglotRoundFactory(random: Random(3)),
    );

void main() {
  group('PolyglotBloc', () {
    test('starts an A1 session with a clamped 4-vertex polygon', () async {
      final bloc = _makeBloc(_jaEntries(6));
      bloc.add(const PolyglotStarted(targetLanguage: 'ja', cefr: CefrLevel.a1));
      final state = await bloc.stream.firstWhere((s) => s is PolyglotInProgress)
          as PolyglotInProgress;
      expect(state.totalVertices, 4);
      expect(state.placedVertices, 0);
      expect(state.round.options.length, 4);
      await bloc.close();
    });

    test('locking every vertex completes the polygon', () async {
      final bloc = _makeBloc(_jaEntries(6));
      bloc.add(const PolyglotStarted(targetLanguage: 'ja', cefr: CefrLevel.a1));
      final first = await bloc.stream.firstWhere((s) => s is PolyglotInProgress)
          as PolyglotInProgress;
      final total = first.totalVertices;

      for (var v = 0; v < total; v++) {
        final correctIdx =
            (bloc.state as PolyglotInProgress).round.correctIndex;
        bloc.add(PolyglotAnswerSelected(correctIdx));
        final next = await bloc.stream.first;
        if (v < total - 1) {
          expect((next as PolyglotInProgress).placedVertices, v + 1);
        } else {
          expect(next, isA<PolyglotComplete>());
          expect((next as PolyglotComplete).totalVertices, total);
        }
      }
      await bloc.close();
    });

    test('a wrong answer distorts without locking a vertex', () async {
      final bloc = _makeBloc(_jaEntries(6));
      bloc.add(const PolyglotStarted(targetLanguage: 'ja', cefr: CefrLevel.a1));
      final state = await bloc.stream.firstWhere((s) => s is PolyglotInProgress)
          as PolyglotInProgress;
      final wrongIdx = state.round.options.indexWhere((o) => !o.isCorrect);

      bloc.add(PolyglotAnswerSelected(wrongIdx));
      final next = await bloc.stream.first as PolyglotInProgress;
      expect(next.placedVertices, 0);
      expect(next.lastAnswerWrong, isTrue);
      expect(next.wrongAttempts, 1);
      await bloc.close();
    });

    test('fails gracefully when vocabulary is too small', () async {
      final bloc = _makeBloc(_jaEntries(1));
      bloc.add(const PolyglotStarted(targetLanguage: 'ja', cefr: CefrLevel.a1));
      final next = await bloc.stream.firstWhere((s) => s is! PolyglotLoading);
      expect(next, isA<PolyglotFailure>());
      await bloc.close();
    });
  });
}
