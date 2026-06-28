part of 'polyglot_bloc.dart';

sealed class PolyglotEvent extends Equatable {
  const PolyglotEvent();
  @override
  List<Object?> get props => [];
}

/// Begin a session translating into [targetLanguage] at [cefr] difficulty.
class PolyglotStarted extends PolyglotEvent {
  const PolyglotStarted({required this.targetLanguage, required this.cefr});
  final String targetLanguage;
  final CefrLevel cefr;
  @override
  List<Object?> get props => [targetLanguage, cefr];
}

/// The learner tapped the option at [optionIndex] in the current round.
class PolyglotAnswerSelected extends PolyglotEvent {
  const PolyglotAnswerSelected(this.optionIndex);
  final int optionIndex;
  @override
  List<Object?> get props => [optionIndex];
}

/// Restart the most recent session from zero vertices.
class PolyglotRestarted extends PolyglotEvent {
  const PolyglotRestarted();
}
