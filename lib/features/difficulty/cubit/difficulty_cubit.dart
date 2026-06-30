import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/difficulty_store.dart';

/// The learner's current math difficulty [band] (from the DDC), persisted so the
/// fact engine can scale fact complexity to their level across sessions (the
/// PRD §6.2 "complexity ceiling derived from ddc_state"). Defaults to beginner.
class DifficultyState extends Equatable {
  const DifficultyState({this.band = 1.0});

  final double band;

  DifficultyState copyWith({double? band}) =>
      DifficultyState(band: band ?? this.band);

  Map<String, dynamic> toMap() => {'band': band};

  factory DifficultyState.fromMap(Map<String, dynamic> m) =>
      DifficultyState(band: (m['band'] as num?)?.toDouble() ?? 1.0);

  @override
  List<Object?> get props => [band];
}

/// Holds the difficulty band and persists it through a [DifficultyStore].
/// Provided above [MaterialApp] so the math flow can update it and the fact
/// engine can read it.
class DifficultyCubit extends Cubit<DifficultyState> {
  DifficultyCubit({DifficultyStore? store})
      : _store = store ?? InMemoryDifficultyStore(),
        super(const DifficultyState());

  final DifficultyStore _store;

  /// Load the saved band at startup (keeps the default on any failure).
  Future<void> hydrate() async {
    try {
      final m = await _store.load();
      if (isClosed) return;
      if (m != null) emit(DifficultyState.fromMap(m));
    } catch (_) {
      // Keep the default beginner band.
    }
  }

  /// Record the learner's latest DDC band (e.g. when they enter a math domain).
  void setBand(double band) {
    if (band == state.band) return;
    final next = state.copyWith(band: band);
    emit(next);
    unawaited(_store.save(next.toMap()));
  }
}
