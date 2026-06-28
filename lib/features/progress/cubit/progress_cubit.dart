import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/progress_store.dart';

/// Stable identifiers for the activities that report completions.
abstract class ActivityIds {
  static const String polyglot = 'polygon_polyglot';
  static const String tessellation = 'isometric_tessellation';
  static const String vector = 'matrix_vector_track';
}

class ProgressState extends Equatable {
  const ProgressState({this.completions = const {}});

  final Map<String, int> completions; // activityId -> completion count

  int get total => completions.values.fold(0, (a, b) => a + b);

  /// Fraction of the way to [goal], clamped to 0..1. The goal itself is a
  /// user setting (see SettingsCubit), kept out of progress so the two concerns
  /// stay separate.
  double progressToward(int goal) =>
      goal <= 0 ? 0 : (total / goal).clamp(0.0, 1.0);

  int completionsOf(String activityId) => completions[activityId] ?? 0;

  /// The activity with the most completions, or null if none recorded yet.
  String? get mostCompletedActivity {
    String? best;
    var bestCount = 0;
    completions.forEach((id, count) {
      if (count > bestCount) {
        bestCount = count;
        best = id;
      }
    });
    return best;
  }

  ProgressState copyWith({Map<String, int>? completions}) =>
      ProgressState(completions: completions ?? this.completions);

  @override
  List<Object?> get props => [completions];
}

/// Provided above [MaterialApp] so every pushed route can record completions and
/// the home screen can display them. Completions are persisted through a
/// [ProgressStore] so the daily goal survives app restarts (PRD §11.3). The
/// default in-memory store keeps tests and dev runs self-contained.
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({ProgressStore? store})
      : _store = store ?? InMemoryProgressStore(),
        super(const ProgressState());

  final ProgressStore _store;

  /// Load any saved completions and emit them. Call once at startup.
  Future<void> hydrate() async {
    final saved = await _store.load();
    if (saved.isNotEmpty) {
      emit(state.copyWith(completions: saved));
    }
  }

  void recordCompletion(String activityId) {
    final next = Map<String, int>.of(state.completions);
    next[activityId] = (next[activityId] ?? 0) + 1;
    emit(state.copyWith(completions: next));
    unawaited(_store.save(next)); // fire-and-forget persistence
  }

  void reset() {
    emit(const ProgressState());
    unawaited(_store.save(const <String, int>{}));
  }
}
