import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/progress/cubit/progress_cubit.dart';
import 'package:taaevon/features/progress/data/progress_store.dart';

void main() {
  group('ProgressCubit', () {
    test('records completions per activity and totals them', () {
      final cubit = ProgressCubit();
      expect(cubit.state.total, 0);

      cubit.recordCompletion(ActivityIds.polyglot);
      cubit.recordCompletion(ActivityIds.polyglot);
      cubit.recordCompletion(ActivityIds.vector);

      expect(cubit.state.completionsOf(ActivityIds.polyglot), 2);
      expect(cubit.state.completionsOf(ActivityIds.vector), 1);
      expect(cubit.state.completionsOf(ActivityIds.tessellation), 0);
      expect(cubit.state.total, 3);
    });

    test('mostCompletedActivity returns the leader, or null when empty', () {
      final cubit = ProgressCubit();
      expect(cubit.state.mostCompletedActivity, isNull);

      cubit.recordCompletion(ActivityIds.vector);
      cubit.recordCompletion(ActivityIds.polyglot);
      cubit.recordCompletion(ActivityIds.polyglot);
      expect(cubit.state.mostCompletedActivity, ActivityIds.polyglot);
    });

    test('progressToward is fractional below the goal', () {
      final cubit = ProgressCubit();
      cubit.recordCompletion(ActivityIds.polyglot);
      expect(cubit.state.progressToward(5), closeTo(0.2, 1e-9)); // 1 / 5
    });

    test('progressToward clamps at 1.0 once the goal is met', () {
      final cubit = ProgressCubit();
      for (var i = 0; i < 10; i++) {
        cubit.recordCompletion(ActivityIds.tessellation);
      }
      expect(cubit.state.total, 10);
      expect(cubit.state.progressToward(5), 1.0);
    });

    test('reset clears all progress', () {
      final cubit = ProgressCubit();
      cubit.recordCompletion(ActivityIds.polyglot);
      cubit.reset();
      expect(cubit.state.total, 0);
    });
  });

  group('ProgressCubit persistence', () {
    test('hydrate loads previously saved completions', () async {
      final store = InMemoryProgressStore();
      await store.save({ActivityIds.polyglot: 3, ActivityIds.vector: 1});

      final cubit = ProgressCubit(store: store);
      expect(cubit.state.total, 0); // nothing until hydrated
      await cubit.hydrate();
      expect(cubit.state.completionsOf(ActivityIds.polyglot), 3);
      expect(cubit.state.total, 4);
    });

    test('completions survive a fresh cubit via the store', () async {
      final store = InMemoryProgressStore();
      final cubit = ProgressCubit(store: store);
      cubit.recordCompletion(ActivityIds.tessellation);
      cubit.recordCompletion(ActivityIds.tessellation);
      await Future<void>.delayed(Duration.zero); // let the save complete

      final reborn = ProgressCubit(store: store);
      await reborn.hydrate();
      expect(reborn.state.completionsOf(ActivityIds.tessellation), 2);
    });

    test('reset also clears the persisted store', () async {
      final store = InMemoryProgressStore();
      final cubit = ProgressCubit(store: store);
      cubit.recordCompletion(ActivityIds.polyglot);
      cubit.reset();
      await Future<void>.delayed(Duration.zero);
      expect(await store.load(), isEmpty);
    });
  });
}
