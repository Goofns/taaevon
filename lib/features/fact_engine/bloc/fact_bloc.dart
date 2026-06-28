import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/fact_entity.dart';
import '../domain/get_random_fact_usecase.dart';

part 'fact_event.dart';
part 'fact_state.dart';

/// Isolated micro-learning fact BLoC. It shares no mutable state with the
/// curriculum BLoCs (PRD §11.2) and tracks per-session delivery in memory so a
/// fact never repeats within a session.
class FactBloc extends Bloc<FactEvent, FactState> {
  FactBloc({required GetRandomFactUseCase getRandomFact})
      : _getRandomFact = getRandomFact,
        super(const FactInitial()) {
    on<FactWarmUpRequested>(_onWarmUp);
    on<FactRequested>(_onRequested);
    on<FactSessionReset>(_onSessionReset);
  }

  final GetRandomFactUseCase _getRandomFact;
  final Set<String> _deliveredIds = <String>{};

  Future<void> _onWarmUp(
    FactWarmUpRequested event,
    Emitter<FactState> emit,
  ) async {
    await _getRandomFact.warmUp();
  }

  Future<void> _onRequested(
    FactRequested event,
    Emitter<FactState> emit,
  ) async {
    emit(const FactLoading());
    final result = await _getRandomFact(
      complexityLevel: event.complexityLevel,
      excludeIds: _deliveredIds,
    );
    switch (result) {
      case FactSuccess(:final fact):
        _deliveredIds.add(fact.factId);
        emit(FactReady(fact));
      case FactExhausted():
        emit(const FactDepleted());
      case FactFailed(:final message):
        emit(FactFailure(message));
    }
  }

  void _onSessionReset(FactSessionReset event, Emitter<FactState> emit) {
    _deliveredIds.clear();
    emit(const FactInitial());
  }
}
