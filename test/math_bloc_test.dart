import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/math/bloc/math_bloc.dart';
import 'package:taaevon/features/sync_engine/dynamic_difficulty_calibrator.dart';

class _StubLexiconRepo implements LexiconRepository {
  _StubLexiconRepo(this._entries);
  final List<LexiconEntry> _entries;

  @override
  Future<List<LexiconEntry>> all() async => _entries;

  @override
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async =>
      _entries.where((e) => e.targetLanguage == targetLanguage).toList();
}

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

MathBloc _bloc() => MathBloc(
      lexicon: _StubLexiconRepo([
        _numeral('いち', 'ichi', 1),
        _numeral('に', 'ni', 2),
        _numeral('さん', 'san', 3),
        _numeral('よん', 'yon', 4),
        _numeral('ご', 'go', 5),
        _numeral('ろく', 'roku', 6),
        _numeral('なな', 'nana', 7),
        _numeral('はち', 'hachi', 8),
        _numeral('きゅう', 'kyuu', 9),
      ]),
      random: Random(5),
    );

void main() {
  group('MathBloc', () {
    test('post-grad band + A1 starts in full interlock with vocabulary',
        () async {
      final bloc = _bloc();
      bloc.add(
        const MathStarted(
          band: 3.0,
          cefr: CefrLevel.a1,
          targetLanguage: 'ja',
        ),
      );
      final s = await bloc.stream.firstWhere((x) => x is MathInProgress)
          as MathInProgress;

      expect(s.mode, InjectionMode.fullInterlock);
      expect(s.problem.glossary, isNotEmpty);
      // The injected operand is rendered as a Japanese numeral, not a digit.
      expect(
          s.problem.prompt.contains(s.problem.glossary.first.script), isTrue);
      await bloc.close();
    });

    test('a correct answer steps the band up (+0.1)', () async {
      final bloc = _bloc();
      bloc.add(const MathStarted(
          band: 3.0, cefr: CefrLevel.a1, targetLanguage: 'ja'));
      final s = await bloc.stream.firstWhere((x) => x is MathInProgress)
          as MathInProgress;

      bloc.add(MathAnswerSubmitted(s.expectedAnswer));
      final next = await bloc.stream.first as MathInProgress;
      expect(next.lastOutcome, AnswerOutcome.correct);
      expect(next.band, closeTo(3.1, 1e-9));
      await bloc.close();
    });

    test('a wrong answer steps the band down (−0.15)', () async {
      final bloc = _bloc();
      bloc.add(const MathStarted(
          band: 3.0, cefr: CefrLevel.a1, targetLanguage: 'ja'));
      final s = await bloc.stream.firstWhere((x) => x is MathInProgress)
          as MathInProgress;

      bloc.add(MathAnswerSubmitted(s.expectedAnswer + 1));
      final next = await bloc.stream.first as MathInProgress;
      expect(next.lastOutcome, AnswerOutcome.incorrect);
      expect(next.band, closeTo(2.85, 1e-9));
      await bloc.close();
    });
  });
}
