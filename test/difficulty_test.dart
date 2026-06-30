import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/difficulty/cubit/difficulty_cubit.dart';
import 'package:taaevon/features/difficulty/data/difficulty_store.dart';
import 'package:taaevon/features/difficulty/domain/difficulty_profile.dart';

void main() {
  group('factComplexityCeiling', () {
    test('is one step above the rounded band, clamped to 1-5', () {
      expect(factComplexityCeiling(0.0), 1); // clamped low
      expect(factComplexityCeiling(1.0), 2); // beginner
      expect(factComplexityCeiling(2.6), 4); // rounds to 3 -> 4
      expect(factComplexityCeiling(3.0), 4); // calculus
      expect(factComplexityCeiling(4.0), 5);
      expect(factComplexityCeiling(5.0), 5); // clamped high
    });
  });

  group('DifficultyCubit', () {
    test('defaults to the beginner band', () {
      expect(DifficultyCubit().state.band, 1.0);
    });

    test('setBand updates the state and persists', () async {
      final store = InMemoryDifficultyStore();
      final cubit = DifficultyCubit(store: store);
      cubit.setBand(3.0);
      expect(cubit.state.band, 3.0);
      await Future<void>.delayed(Duration.zero); // let unawaited save run
      final saved = await store.load();
      expect((saved!['band'] as num).toDouble(), 3.0);
    });

    test('setBand to the current value is a no-op', () {
      final cubit = DifficultyCubit();
      cubit.setBand(1.0); // already the default
      expect(cubit.state.band, 1.0);
    });

    test('hydrate restores a saved band', () async {
      final store = InMemoryDifficultyStore();
      await store.save({'band': 4.0});
      final cubit = DifficultyCubit(store: store);
      await cubit.hydrate();
      expect(cubit.state.band, 4.0);
    });

    test('hydrate keeps the default when nothing is saved', () async {
      final cubit = DifficultyCubit(store: InMemoryDifficultyStore());
      await cubit.hydrate();
      expect(cubit.state.band, 1.0);
    });
  });
}
