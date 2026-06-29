import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../language/data/lexicon_repository.dart';
import '../../language/domain/lexicon_entry.dart';
import '../../sync_engine/dynamic_difficulty_calibrator.dart';
import '../../sync_engine/interlocking_progression.dart';
import '../domain/math_problem_bank.dart';

part 'math_event.dart';
part 'math_state.dart';

/// Serves math problems, applies the cross-domain injector (so an advanced
/// problem can be posed with beginner-script number-words), checks answers, and
/// recalibrates difficulty with the DDC step function after each response.
class MathBloc extends Bloc<MathEvent, MathState> {
  MathBloc({
    required LexiconRepository lexicon,
    MathProblemBank? bank,
    InterlockingProgression? injector,
    Random? random,
  })  : _lexicon = lexicon,
        _bank = bank ?? MathProblemBank(),
        _injector = injector ?? const InterlockingProgression(),
        _rng = random ?? Random(),
        super(const MathInitial()) {
    on<MathStarted>(_onStarted);
    on<MathAnswerSubmitted>(_onAnswer);
    on<MathNextRequested>(_onNext);
  }

  final LexiconRepository _lexicon;
  final MathProblemBank _bank;
  final InterlockingProgression _injector;
  final Random _rng;

  static const int _targetMs = 2000;
  static const int _historyWindow = 5;

  double _band = 1.0;
  CefrLevel _cefr = CefrLevel.a1;
  List<LexiconEntry> _vocab = const [];
  final List<bool> _history = [];
  int _expected = 0;

  Future<void> _onStarted(MathStarted event, Emitter<MathState> emit) async {
    emit(const MathLoading());
    try {
      _band = event.band;
      _cefr = event.cefr;
      _vocab = await _lexicon.entriesForTarget(event.targetLanguage);
      _history.clear();
      emit(_nextProblem(AnswerOutcome.none));
    } catch (err) {
      emit(MathFailure(err.toString()));
    }
  }

  void _onAnswer(MathAnswerSubmitted event, Emitter<MathState> emit) {
    if (state is! MathInProgress) return;
    final correct = event.value == _expected;

    _history.add(correct);
    if (_history.length > _historyWindow) _history.removeAt(0);
    final accuracy = _history.where((c) => c).length / _history.length;

    final ddc = DynamicDifficultyCalibrator.calibrate(
      currentLevel: _band,
      accuracy: accuracy,
      avgResponseMs: _targetMs, // neutral efficiency term for the live demo
      targetResponseMs: _targetMs,
      bandFloor: 1.0,
      bandCeiling: 3.99,
    );
    _band = ddc.calibratedLevel;

    emit(_nextProblem(
        correct ? AnswerOutcome.correct : AnswerOutcome.incorrect));
  }

  void _onNext(MathNextRequested event, Emitter<MathState> emit) {
    if (state is! MathInProgress) return;
    emit(_nextProblem(AnswerOutcome.none));
  }

  MathInProgress _nextProblem(AnswerOutcome outcome) {
    final mode = DynamicDifficultyCalibrator.decideInjectionMode(_band, _cefr);
    final template = _bank.forBand(_band, _rng);
    final bindings = _bindings(template.variableNames, mode);

    final injected = _injector.inject(
      template: template.promptTemplate,
      bindings: bindings,
      targetVocab: _vocab,
      mode: mode,
    );
    _expected = template.computeAnswer(bindings);

    return MathInProgress(
      problem: injected,
      expectedAnswer: _expected,
      band: _band,
      mode: mode,
      lastOutcome: outcome,
    );
  }

  Map<String, int> _bindings(List<String> names, InjectionMode mode) {
    if (mode == InjectionMode.languageSeedsMath && _vocab.isNotEmpty) {
      return _injector.seedBindingsFromVocab(names, _vocab);
    }
    // Keep operands in 1..9 so they map to seeded number-words (the lexicon
    // carries 1–10) when the math/language tracks interlock.
    return {for (final n in names) n: 1 + _rng.nextInt(9)};
  }
}
