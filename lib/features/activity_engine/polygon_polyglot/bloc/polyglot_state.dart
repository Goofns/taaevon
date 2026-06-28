part of 'polyglot_bloc.dart';

sealed class PolyglotState extends Equatable {
  const PolyglotState();
  @override
  List<Object?> get props => [];
}

class PolyglotInitial extends PolyglotState {
  const PolyglotInitial();
}

class PolyglotLoading extends PolyglotState {
  const PolyglotLoading();
}

/// An active polygon: [placedVertices] of [totalVertices] locked in.
class PolyglotInProgress extends PolyglotState {
  const PolyglotInProgress({
    required this.round,
    required this.placedVertices,
    required this.totalVertices,
    required this.lastAnswerWrong,
    required this.wrongAttempts,
  });

  final PolyglotRound round;
  final int placedVertices;
  final int totalVertices;
  final bool lastAnswerWrong;
  final int wrongAttempts; // monotonic; drives the shake animation key

  @override
  List<Object?> get props =>
      [round, placedVertices, totalVertices, lastAnswerWrong, wrongAttempts];
}

/// The polygon is solved — every vertex placed.
class PolyglotComplete extends PolyglotState {
  const PolyglotComplete({required this.totalVertices});
  final int totalVertices;
  @override
  List<Object?> get props => [totalVertices];
}

class PolyglotFailure extends PolyglotState {
  const PolyglotFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
