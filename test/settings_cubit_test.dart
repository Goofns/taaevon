import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/settings/cubit/settings_cubit.dart';
import 'package:taaevon/features/settings/data/settings_store.dart';

void main() {
  group('SettingsCubit', () {
    test('defaults to a goal of 5 with motion enabled', () {
      final cubit = SettingsCubit();
      expect(cubit.state.dailyGoal, 5);
      expect(cubit.state.reduceMotion, isFalse);
    });

    test('setDailyGoal clamps to the allowed range', () {
      final cubit = SettingsCubit();
      cubit.setDailyGoal(100);
      expect(cubit.state.dailyGoal, SettingsCubit.maxGoal);
      cubit.setDailyGoal(0);
      expect(cubit.state.dailyGoal, SettingsCubit.minGoal);
    });

    test('settings persist and hydrate via the store', () async {
      final store = InMemorySettingsStore();
      final cubit = SettingsCubit(store: store);
      cubit.setDailyGoal(8);
      cubit.setReduceMotion(true);
      await Future<void>.delayed(Duration.zero); // let the saves complete

      final reborn = SettingsCubit(store: store);
      await reborn.hydrate();
      expect(reborn.state.dailyGoal, 8);
      expect(reborn.state.reduceMotion, isTrue);
    });

    test('toMap/fromMap round-trips persisted fields', () {
      const s = SettingsState(
        dailyGoal: 7,
        reduceMotion: true,
        onboardingSeen: true,
      );
      expect(SettingsState.fromMap(s.toMap()), s);
    });

    test('hydrate marks state hydrated even with no saved settings', () async {
      final cubit = SettingsCubit(store: InMemorySettingsStore());
      expect(cubit.state.hydrated, isFalse);
      await cubit.hydrate();
      expect(cubit.state.hydrated, isTrue);
      expect(cubit.state.onboardingSeen, isFalse); // new user
    });

    test('completeOnboarding sets and persists the seen flag', () async {
      final store = InMemorySettingsStore();
      final cubit = SettingsCubit(store: store);
      cubit.completeOnboarding();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.onboardingSeen, isTrue);

      final reborn = SettingsCubit(store: store);
      await reborn.hydrate();
      expect(reborn.state.onboardingSeen, isTrue);
    });
  });
}
