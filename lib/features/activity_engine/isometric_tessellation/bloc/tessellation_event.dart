part of 'tessellation_bloc.dart';

sealed class TessellationEvent extends Equatable {
  const TessellationEvent();
  @override
  List<Object?> get props => [];
}

class TessellationStarted extends TessellationEvent {
  const TessellationStarted();
}

/// Submit an answer to the current problem; a correct answer earns one tile.
class TessellationAnswerSubmitted extends TessellationEvent {
  const TessellationAnswerSubmitted(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}

/// Attempt to place an earned tile at [cell].
class TessellationCellTapped extends TessellationEvent {
  const TessellationCellTapped(this.cell);
  final Cell cell;
  @override
  List<Object?> get props => [cell];
}
