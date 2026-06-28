import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../language/data/lexicon_repository.dart';
import '../../../language/domain/lexicon_entry.dart';
import '../../../sync_engine/dynamic_difficulty_calibrator.dart';
import '../domain/polyglot_difficulty.dart';
import '../domain/polyglot_round.dart';
import '../domain/polyglot_round_factory.dart';

part 'polyglot_event.dart';
part 'polyglot_state.dart';

/// Drives the Polygon Polyglot geometric state machine (PRD §9.2):
/// a correct translation locks a vertex; a wrong one distorts the polygon and
/// reshuffles the same word's options; placing every vertex solves the polygon.
class PolyglotBloc extends Bloc<PolyglotEvent, PolyglotState> {
  PolyglotBloc({
    required LexiconRepository repository,
    PolyglotRoundFactory? roundFactory,
  })  : _repo = repository,
        _factory = roundFactory ?? PolyglotRoundFactory(),
        super(const PolyglotInitial()) {
    on<PolyglotStarted>(_onStarted);
    on<PolyglotAnswerSelected>(_onAnswer);
    on<PolyglotRestarted>(_onRestarted);
  }

  final LexiconRepository _repo;
  final PolyglotRoundFactory _factory;

  List<LexiconEntry> _pool = const [];
  List<LexiconEntry> _queue = const []; // one target word per vertex
  int _optionCount = 4;
  int _placed = 0;
  int _total = 0;
  int _wrongAttempts = 0;
  PolyglotStarted? _lastStart;

  Future<void> _onStarted(
    PolyglotStarted event,
    Emitter<PolyglotState> emit,
  ) async {
    _lastStart = event;
    emit(const PolyglotLoading());
    try {
      final pool = await _repo.entriesForTarget(event.targetLanguage);
      if (pool.length < 2) {
        emit(const PolyglotFailure('Not enough vocabulary for this language.'));
        return;
      }

      final diff = PolyglotDifficulty.forCefr(event.cefr);
      _pool = pool;
      // Clamp to the available pool so small datasets never starve a round.
      _total = math.max(2, math.min(diff.polygonSides, pool.length));
      _optionCount = math.max(2, math.min(diff.optionCount, pool.length));
      _queue = ([...pool]..shuffle(_factory.random)).take(_total).toList();
      _placed = 0;
      _wrongAttempts = 0;
      emit(_inProgress(lastWrong: false));
    } catch (err) {
      emit(PolyglotFailure(err.toString()));
    }
  }

  void _onAnswer(PolyglotAnswerSelected event, Emitter<PolyglotState> emit) {
    final current = state;
    if (current is! PolyglotInProgress) return;
    if (event.optionIndex < 0 ||
        event.optionIndex >= current.round.options.length) {
      return;
    }

    final correct = current.round.options[event.optionIndex].isCorrect;
    if (correct) {
      _placed += 1;
      if (_placed >= _total) {
        emit(PolyglotComplete(totalVertices: _total));
        return;
      }
      emit(_inProgress(lastWrong: false));
    } else {
      _wrongAttempts += 1;
      // Same word, reshuffled options (PRD §9.2).
      emit(_inProgress(lastWrong: true));
    }
  }

  void _onRestarted(PolyglotRestarted event, Emitter<PolyglotState> emit) {
    final start = _lastStart;
    if (start != null) add(start);
  }

  PolyglotInProgress _inProgress({required bool lastWrong}) {
    final round = _factory.build(
      target: _queue[_placed],
      pool: _pool,
      optionCount: _optionCount,
    );
    return PolyglotInProgress(
      round: round,
      placedVertices: _placed,
      totalVertices: _total,
      lastAnswerWrong: lastWrong,
      wrongAttempts: _wrongAttempts,
    );
  }
}
