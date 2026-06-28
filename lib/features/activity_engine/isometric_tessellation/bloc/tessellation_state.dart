part of 'tessellation_bloc.dart';

enum TileOutcome { none, earned, missed }

sealed class TessellationState extends Equatable {
  const TessellationState();
  @override
  List<Object?> get props => [];
}

class TessellationInitial extends TessellationState {
  const TessellationInitial();
}

class TessellationInProgress extends TessellationState {
  const TessellationInProgress({
    required this.filled,
    required this.credits,
    required this.prompt,
    required this.expectedAnswer,
    required this.rows,
    required this.cols,
    required this.lastOutcome,
  });

  final Set<Cell> filled;
  final int credits; // earned-but-unplaced tiles
  final String prompt;
  final int expectedAnswer; // checked internally; never shown
  final int rows;
  final int cols;
  final TileOutcome lastOutcome;

  int get placed => filled.length;
  int get total => rows * cols;

  @override
  List<Object?> get props => [filled, credits, prompt, lastOutcome];
}

class TessellationComplete extends TessellationState {
  const TessellationComplete({required this.total});
  final int total;
  @override
  List<Object?> get props => [total];
}
