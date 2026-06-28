part of 'math_bloc.dart';

sealed class MathEvent extends Equatable {
  const MathEvent();
  @override
  List<Object?> get props => [];
}

/// Begin a math session at [band] (1.0–3.99) with the learner's [cefr] level in
/// [targetLanguage] (used by the cross-domain injector).
class MathStarted extends MathEvent {
  const MathStarted({
    required this.band,
    required this.cefr,
    required this.targetLanguage,
  });
  final double band;
  final CefrLevel cefr;
  final String targetLanguage;
  @override
  List<Object?> get props => [band, cefr, targetLanguage];
}

class MathAnswerSubmitted extends MathEvent {
  const MathAnswerSubmitted(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}

class MathNextRequested extends MathEvent {
  const MathNextRequested();
}
