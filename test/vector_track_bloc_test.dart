import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/bloc/vector_track_bloc.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/domain/vector_track.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';

import 'support/stub_lexicon_repo.dart';

LexiconEntry _numeral(String script, int value) => LexiconEntry(
      wordId: 'ja-$value',
      sourceLanguage: 'en',
      targetLanguage: 'ja',
      baseTerm: '$value',
      translatedTerm: script,
      lexicalCategory: 'everyday',
      partOfSpeech: 'numeral',
      syllableCount: 1,
      mathExtractedValue: value,
    );

VectorTrackBloc _bloc() => VectorTrackBloc(
      lexicon: StubLexiconRepo([
        _numeral('いち', 1),
        _numeral('に', 2),
        _numeral('さん', 3),
      ]),
      random: Random(7),
    );

void main() {
  group('VectorTrackBloc', () {
    test('labels columns with target-language number-words', () async {
      final bloc = _bloc();
      bloc.add(const VectorStarted(targetLanguage: 'ja', gridSize: 3));
      final s = await bloc.stream.firstWhere((x) => x is VectorInProgress)
          as VectorInProgress;
      expect(s.columnWords[0], 'いち'); // value 1
      expect(s.columnWords[1], 'に'); // value 2
      expect(s.columnWords[2], 'さん'); // value 3
      expect(s.current, const VectorPos(0, 0));
      expect(s.target == const VectorPos(0, 0), isFalse); // never the origin
      await bloc.close();
    });

    test('navigating the vector onto the target completes the track', () async {
      final bloc = _bloc();
      bloc.add(const VectorStarted(targetLanguage: 'ja', gridSize: 3));
      final s = await bloc.stream.firstWhere((x) => x is VectorInProgress)
          as VectorInProgress;
      final target = s.target;

      final moves = <VectorDirection>[
        ...List.filled(target.row, VectorDirection.down),
        ...List.filled(target.col, VectorDirection.right),
      ];
      VectorTrackState? last;
      for (final d in moves) {
        bloc.add(VectorMoved(d));
        last = await bloc.stream.first;
      }
      expect(last, isA<VectorComplete>());
      expect((last as VectorComplete).moves, target.row + target.col);
      await bloc.close();
    });
  });
}
