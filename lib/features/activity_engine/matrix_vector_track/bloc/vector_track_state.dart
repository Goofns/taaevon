part of 'vector_track_bloc.dart';

sealed class VectorTrackState extends Equatable {
  const VectorTrackState();
  @override
  List<Object?> get props => [];
}

class VectorInitial extends VectorTrackState {
  const VectorInitial();
}

class VectorLoading extends VectorTrackState {
  const VectorLoading();
}

class VectorInProgress extends VectorTrackState {
  const VectorInProgress({
    required this.gridSize,
    required this.current,
    required this.target,
    required this.columnWords,
    required this.moves,
  });

  final int gridSize;
  final VectorPos current;
  final VectorPos target;

  /// Column index → target-language number-word (e.g. 2 → さん). The learner
  /// must read these to find the target column.
  final Map<int, String> columnWords;
  final int moves;

  String get targetColumnWord => columnWords[target.col] ?? '${target.col + 1}';

  @override
  List<Object?> get props => [gridSize, current, target, moves];
}

class VectorComplete extends VectorTrackState {
  const VectorComplete({required this.moves});
  final int moves;
  @override
  List<Object?> get props => [moves];
}

class VectorFailure extends VectorTrackState {
  const VectorFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
