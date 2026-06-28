import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/streak/cubit/streak_cubit.dart';
import 'package:taaevon/features/streak/data/streak_store.dart';

void main() {
  group('StreakCubit', () {
    test('records across days using the injected clock and persists', () async {
      var now = DateTime(2026, 6, 27);
      final store = InMemoryStreakStore();
      final cubit = StreakCubit(store: store, clock: () => now);

      cubit.recordActivity();
      expect(cubit.state.count, 1);

      // Same day again — no change.
      cubit.recordActivity();
      expect(cubit.state.count, 1);

      now = DateTime(2026, 6, 28);
      cubit.recordActivity();
      expect(cubit.state.count, 2);
      await Future<void>.delayed(Duration.zero); // let the save complete

      final reborn = StreakCubit(store: store, clock: () => now);
      await reborn.hydrate();
      expect(reborn.state.count, 2);
      expect(reborn.state.lastActiveDate, '2026-06-28');
    });

    test('hydrate marks hydrated even with no saved streak', () async {
      final cubit = StreakCubit(store: InMemoryStreakStore());
      expect(cubit.state.hydrated, isFalse);
      await cubit.hydrate();
      expect(cubit.state.hydrated, isTrue);
      expect(cubit.state.count, 0);
    });
  });
}
