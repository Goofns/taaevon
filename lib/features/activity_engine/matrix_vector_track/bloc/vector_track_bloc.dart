import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../language/data/lexicon_repository.dart';
import '../domain/vector_track.dart';

part 'vector_track_event.dart';
part 'vector_track_state.dart';

/// Matrix Vector Track engine (PRD §9.3). Builds a grid whose columns are
/// labelled with target-language number-words, sets a random target node, and
/// lets the learner steer the vector head with directional moves until it lands
/// on the target — fusing spatial coordinates with number vocabulary.
class VectorTrackBloc extends Bloc<VectorTrackEvent, VectorTrackState> {
  VectorTrackBloc({required LexiconRepository lexicon, Random? random})
      : _lexicon = lexicon,
        _rng = random ?? Random(),
        super(const VectorInitial()) {
    on<VectorStarted>(_onStarted);
    on<VectorMoved>(_onMoved);
    on<VectorRestarted>(_onRestarted);
  }

  final LexiconRepository _lexicon;
  final Random _rng;

  int _gridSize = 3;
  VectorPos _current = const VectorPos(0, 0);
  VectorPos _target = const VectorPos(0, 0);
  Map<int, String> _columnWords = const {};
  int _moves = 0;
  VectorStarted? _lastStart;

  Future<void> _onStarted(
    VectorStarted event,
    Emitter<VectorTrackState> emit,
  ) async {
    _lastStart = event;
    emit(const VectorLoading());
    try {
      final pool = await _lexicon.entriesForTarget(event.targetLanguage);
      final valueWord = <int, String>{
        for (final e in pool.where((e) => e.isNumeral))
          e.mathExtractedValue: e.translatedTerm,
      };

      _gridSize = event.gridSize;
      _columnWords = {
        for (var c = 0; c < _gridSize; c++) c: valueWord[c + 1] ?? '${c + 1}',
      };
      _current = const VectorPos(0, 0);
      _moves = 0;
      _target = _randomTarget();
      emit(_inProgress());
    } catch (err) {
      emit(VectorFailure(err.toString()));
    }
  }

  void _onMoved(VectorMoved event, Emitter<VectorTrackState> emit) {
    if (state is! VectorInProgress) return;
    _current = VectorTrackRules.move(_current, event.direction, _gridSize);
    _moves += 1;
    if (VectorTrackRules.atTarget(_current, _target)) {
      emit(VectorComplete(moves: _moves));
      return;
    }
    emit(_inProgress());
  }

  void _onRestarted(VectorRestarted event, Emitter<VectorTrackState> emit) {
    final start = _lastStart;
    if (start != null) add(start);
  }

  VectorPos _randomTarget() {
    VectorPos t;
    do {
      t = VectorPos(_rng.nextInt(_gridSize), _rng.nextInt(_gridSize));
    } while (t.row == 0 && t.col == 0); // never the start node
    return t;
  }

  VectorInProgress _inProgress() => VectorInProgress(
        gridSize: _gridSize,
        current: _current,
        target: _target,
        columnWords: _columnWords,
        moves: _moves,
      );
}
