import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/isometric_tessellation/bloc/tessellation_bloc.dart';
import 'package:taaevon/features/activity_engine/isometric_tessellation/domain/tessellation_board.dart';

void main() {
  group('TessellationBloc', () {
    test('starts with an empty 2x2 panel and no credits', () async {
      final bloc = TessellationBloc(rows: 2, cols: 2, random: Random(1));
      bloc.add(const TessellationStarted());
      final s = await bloc.stream.first as TessellationInProgress;
      expect(s.credits, 0);
      expect(s.filled, isEmpty);
      expect(s.total, 4);
      await bloc.close();
    });

    test('a correct answer earns a tile', () async {
      final bloc = TessellationBloc(rows: 2, cols: 2, random: Random(1));
      bloc.add(const TessellationStarted());
      final start = await bloc.stream.first as TessellationInProgress;
      bloc.add(TessellationAnswerSubmitted(start.expectedAnswer));
      final next = await bloc.stream.first as TessellationInProgress;
      expect(next.credits, 1);
      expect(next.lastOutcome, TileOutcome.earned);
      await bloc.close();
    });

    test('placing with no earned tiles is a no-op', () async {
      final bloc = TessellationBloc(rows: 2, cols: 2, random: Random(2));
      bloc.add(const TessellationStarted());
      await bloc.stream.first;
      bloc.add(const TessellationCellTapped(Cell(0, 0)));
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state as TessellationInProgress).filled, isEmpty);
      await bloc.close();
    });

    test('earning then placing every tile completes the panel', () async {
      final bloc = TessellationBloc(rows: 2, cols: 2, random: Random(3));
      bloc.add(const TessellationStarted());
      await bloc.stream.first;

      for (var i = 0; i < 4; i++) {
        final cur = bloc.state as TessellationInProgress;
        bloc.add(TessellationAnswerSubmitted(cur.expectedAnswer));
        await bloc.stream.first;
      }
      expect((bloc.state as TessellationInProgress).credits, 4);

      const cells = [Cell(0, 0), Cell(0, 1), Cell(1, 0), Cell(1, 1)];
      TessellationState? last;
      for (final c in cells) {
        bloc.add(TessellationCellTapped(c));
        last = await bloc.stream.first;
      }
      expect(last, isA<TessellationComplete>());
      expect((last as TessellationComplete).total, 4);
      await bloc.close();
    });
  });
}
