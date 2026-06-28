import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/settings_store.dart';

/// User-adjustable settings, including accessibility options (PRD §14).
class SettingsState extends Equatable {
  const SettingsState({
    this.dailyGoal = 5,
    this.reduceMotion = false,
    this.onboardingSeen = false,
    this.hydrated = false,
  });

  /// Number of activity completions that fills the home daily-goal bar.
  final int dailyGoal;

  /// When true, non-essential animations (e.g. the polygon shake) are skipped.
  final bool reduceMotion;

  /// True once the first-run onboarding has been completed.
  final bool onboardingSeen;

  /// Transient (not persisted): true once settings have loaded from the store,
  /// so the root gate can wait before deciding home vs. onboarding.
  final bool hydrated;

  SettingsState copyWith({
    int? dailyGoal,
    bool? reduceMotion,
    bool? onboardingSeen,
    bool? hydrated,
  }) =>
      SettingsState(
        dailyGoal: dailyGoal ?? this.dailyGoal,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
        hydrated: hydrated ?? this.hydrated,
      );

  // `hydrated` is deliberately excluded — it is runtime-only, not persisted.
  Map<String, dynamic> toMap() => {
        'dailyGoal': dailyGoal,
        'reduceMotion': reduceMotion,
        'onboardingSeen': onboardingSeen,
      };

  factory SettingsState.fromMap(Map<String, dynamic> m) => SettingsState(
        dailyGoal: (m['dailyGoal'] as num?)?.toInt() ?? 5,
        reduceMotion: m['reduceMotion'] as bool? ?? false,
        onboardingSeen: m['onboardingSeen'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [dailyGoal, reduceMotion, onboardingSeen, hydrated];
}

/// Holds settings and persists them through a [SettingsStore]. Provided above
/// [MaterialApp] so any screen can read or change them.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({SettingsStore? store})
      : _store = store ?? InMemorySettingsStore(),
        super(const SettingsState());

  final SettingsStore _store;

  static const int minGoal = 1;
  static const int maxGoal = 20;

  /// Always emits with `hydrated: true` (even when nothing is saved) so the
  /// root gate can stop showing its loader and decide home vs. onboarding.
  Future<void> hydrate() async {
    final m = await _store.load();
    final loaded = m == null ? const SettingsState() : SettingsState.fromMap(m);
    emit(loaded.copyWith(hydrated: true));
  }

  void setDailyGoal(int goal) {
    final clamped = goal < minGoal ? minGoal : (goal > maxGoal ? maxGoal : goal);
    if (clamped == state.dailyGoal) return;
    final next = state.copyWith(dailyGoal: clamped);
    emit(next);
    unawaited(_store.save(next.toMap()));
  }

  void setReduceMotion(bool value) {
    final next = state.copyWith(reduceMotion: value);
    emit(next);
    unawaited(_store.save(next.toMap()));
  }

  void completeOnboarding() {
    if (state.onboardingSeen) return;
    final next = state.copyWith(onboardingSeen: true);
    emit(next);
    unawaited(_store.save(next.toMap()));
  }
}
