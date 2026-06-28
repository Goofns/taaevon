import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/streak_store.dart';
import '../domain/streak.dart';

/// Tracks the consecutive-day practice streak. Provided above [MaterialApp];
/// activities call [recordActivity] when completed. A clock is injectable so the
/// date logic is testable.
class StreakCubit extends Cubit<Streak> {
  StreakCubit({StreakStore? store, DateTime Function()? clock})
      : _store = store ?? InMemoryStreakStore(),
        _clock = clock ?? DateTime.now,
        super(const Streak());

  final StreakStore _store;
  final DateTime Function() _clock;

  Future<void> hydrate() async {
    final m = await _store.load();
    final loaded = m == null ? const Streak() : Streak.fromMap(m);
    emit(loaded.copyWith(hydrated: true));
  }

  /// Record that an activity was completed now; updates the streak if it's a
  /// new day, otherwise leaves it unchanged.
  void recordActivity() {
    final next = StreakCalculator.recordActivity(state, _clock());
    if (next == state) return;
    emit(next);
    unawaited(_store.save(next.toMap()));
  }
}
