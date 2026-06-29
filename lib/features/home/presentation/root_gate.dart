import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../settings/cubit/settings_cubit.dart';
import 'home_screen.dart';

/// Chooses the first screen once settings have hydrated: the onboarding screen
/// on first run, otherwise the home screen. Shows a brief loader until hydration
/// completes so onboarding never flashes for returning users.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, s) {
        if (!s.hydrated) {
          return const Scaffold(
            backgroundColor: TaaevonColors.backgroundBase,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TaaevonColors.primaryAction,
              ),
            ),
          );
        }
        return s.onboardingSeen ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
