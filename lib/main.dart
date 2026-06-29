import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/fact_engine/bloc/fact_bloc.dart';
import 'features/fact_engine/data/fact_local_datasource.dart';
import 'features/fact_engine/data/fact_repository.dart';
import 'features/fact_engine/domain/get_random_fact_usecase.dart';
import 'features/home/presentation/root_gate.dart';
import 'features/progress/cubit/progress_cubit.dart';
import 'features/progress/data/progress_store.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/data/settings_store.dart';
import 'features/streak/cubit/streak_cubit.dart';
import 'features/streak/data/streak_store.dart';

void main() {
  // Top-level guard: a stray uncaught async error (e.g. a fire-and-forget cubit
  // hydrate that fails) is logged rather than silently killing the app.
  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint(
          'Taaevon: uncaught Flutter error: ${details.exceptionAsString()}',
        );
      };
      // NOTE: on devices with ProMotion / high-refresh displays, request 120 Hz
      // here via flutter_display_mode once that dependency is enabled (PRD §11.1).
      runApp(const TaaevonApp());
    },
    (error, stack) => debugPrint('Taaevon: uncaught async error: $error'),
  );
}

class TaaevonApp extends StatelessWidget {
  const TaaevonApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ProgressCubit and SettingsCubit sit above MaterialApp so every pushed
    // route can read them. Both hydrate from shared preferences so progress and
    // settings persist across restarts.
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProgressCubit>(
          create: (_) =>
              ProgressCubit(store: SharedPrefsProgressStore())..hydrate(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) =>
              SettingsCubit(store: SharedPrefsSettingsStore())..hydrate(),
        ),
        BlocProvider<StreakCubit>(
          create: (_) =>
              StreakCubit(store: SharedPrefsStreakStore())..hydrate(),
        ),
        // FactBloc lives at the root so the micro-learning interstitial can be
        // shown during navigation transitions, not just on the home screen.
        BlocProvider<FactBloc>(
          create: (_) => FactBloc(
            getRandomFact: GetRandomFactUseCase(
              repository: FactRepository(local: FactLocalDataSource()),
            ),
          )..add(const FactWarmUpRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Taaevon',
        debugShowCheckedModeBanner: false,
        theme: TaaevonTheme.light(),
        // Clamp OS text scaling to <=1.5x. The geometric tile/card layouts are
        // built for a bounded range; beyond ~1.5x they would clip. (Full 200%
        // support would need intrinsic-height layouts — a follow-up.)
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(maxScaleFactor: 1.5),
            ),
            child: child!,
          );
        },
        home: const RootGate(),
      ),
    );
  }
}
