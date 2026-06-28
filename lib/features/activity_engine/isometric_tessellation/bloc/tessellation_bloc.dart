import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../math/domain/math_problem_bank.dart';
import '../domain/tessellation_board.dart';

part 'tessellation_event.dart';
part 'tessellation_state.dart';

/// Isometric Tessellation engine (PRD §9.4): solving an arithmetic problem
/// earns a tile; an earned tile is placed on an empty cell adjacent to the
/// growing pattern; filling the panel completes it.
class TessellationBloc extends Bloc<TessellationEvent, TessellationState> {
  TessellationBloc({
    MathProblemBank? bank,
    Random? random,
    this.rows = 3,
    this.cols = 3,
    this.problemBand = 1.5,
  })  : _bank = bank ?? MathProblemBank(),
        _rng = random ?? Random(),
        super(const TessellationInitial()) {
    on<TessellationStarted>(_onStarted);
    on<TessellationAnswerSubmitted>(_onAnswer);
    on<TessellationCellTapped>(_onCellTapped);
  }

  final MathProblemBank _bank;
  final Random _rng;
  final int rows;
  final int cols;
  final double problemBand;

  final Set<Cell> _filled = {};
  int _credits = 0;
  String _prompt = '';
  int _expected = 0;

  void _onStarted(TessellationStarted event, Emitter<TessellationState> emit) {
    _filled.clear();
    _credits = 0;
    _generateProblem();
    emit(_inProgress(TileOutcome.none));
  }

  void _onAnswer(
    TessellationAnswerSubmitted event,
    Emitter<TessellationState> emit,
  ) {
    if (state is! TessellationInProgress) return;
    final correct = event.value == _expected;
    if (correct) _credits += 1;
    _generateProblem();
    emit(_inProgress(correct ? TileOutcome.earned : TileOutcome.missed));
  }

  void _onCellTapped(
    TessellationCellTapped event,
    Emitter<TessellationState> emit,
  ) {
    if (state is! TessellationInProgress) return;
    if (_credits <= 0) return; // nothing to place
    if (!TessellationBoard.canPlace(_filled, event.cell, rows, cols)) return;

    _filled.add(event.cell);
    _credits -= 1;
    if (TessellationBoard.isFull(_filled, rows, cols)) {
      emit(TessellationComplete(total: rows * cols));
      return;
    }
    emit(_inProgress(TileOutcome.none));
  }

  void _generateProblem() {
    final template = _bank.forBand(problemBand, _rng);
    final bindings = {
      for (final n in template.variableNames) n: 1 + _rng.nextInt(9),
    };
    _prompt = _render(template.promptTemplate, bindings);
    _expected = template.computeAnswer(bindings);
  }

  static String _render(String template, Map<String, int> bindings) {
    var out = template;
    bindings.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
    return out;
  }

  TessellationInProgress _inProgress(TileOutcome outcome) {
    return TessellationInProgress(
      filled: Set<Cell>.of(_filled),
      credits: _credits,
      prompt: _prompt,
      expectedAnswer: _expected,
      rows: rows,
      cols: cols,
      lastOutcome: outcome,
    );
  }
}
