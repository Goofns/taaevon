part of 'fact_bloc.dart';

sealed class FactEvent extends Equatable {
  const FactEvent();
  @override
  List<Object?> get props => [];
}

/// Request a fresh fact, filtered to [complexityLevel] (1–5).
class FactRequested extends FactEvent {
  const FactRequested({this.complexityLevel = 3});
  final int complexityLevel;
  @override
  List<Object?> get props => [complexityLevel];
}

/// Pre-load the data source so the first real request is instant.
class FactWarmUpRequested extends FactEvent {
  const FactWarmUpRequested();
}

/// Clear the per-session seen set (e.g. on a new session).
class FactSessionReset extends FactEvent {
  const FactSessionReset();
}
