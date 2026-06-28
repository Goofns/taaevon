part of 'math_bloc.dart';

enum AnswerOutcome { none, correct, incorrect }

sealed class MathState extends Equatable {
  const MathState();
  @override
  List<Object?> get props => [];
}

class MathInitial extends MathState {
  const MathInitial();
}

class MathLoading extends MathState {
  const MathLoading();
}

/// A live problem. [problem] is post-injection (its prompt may contain
/// target-language number-words); [glossary] surfaces the vocabulary touched.
/// [expectedAnswer] is held here for checking — the UI never displays it.
class MathInProgress extends MathState {
  const MathInProgress({
    required this.problem,
    required this.expectedAnswer,
    required this.band,
    required this.mode,
    required this.lastOutcome,
  });

  final InjectedProblem problem;
  final int expectedAnswer;
  final double band;
  final InjectionMode mode;
  final AnswerOutcome lastOutcome;

  @override
  List<Object?> get props =>
      [problem.prompt, expectedAnswer, band, mode, lastOutcome];
}

class MathFailure extends MathState {
  const MathFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
