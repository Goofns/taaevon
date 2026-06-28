part of 'vector_track_bloc.dart';

sealed class VectorTrackEvent extends Equatable {
  const VectorTrackEvent();
  @override
  List<Object?> get props => [];
}

class VectorStarted extends VectorTrackEvent {
  const VectorStarted({required this.targetLanguage, this.gridSize = 3});
  final String targetLanguage;
  final int gridSize;
  @override
  List<Object?> get props => [targetLanguage, gridSize];
}

class VectorMoved extends VectorTrackEvent {
  const VectorMoved(this.direction);
  final VectorDirection direction;
  @override
  List<Object?> get props => [direction];
}

class VectorRestarted extends VectorTrackEvent {
  const VectorRestarted();
}
