import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../about/presentation/about_screen.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SETTINGS', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('settings'),
        child: SafeArea(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, s) {
              final cubit = context.read<SettingsCubit>();
              return ListView(
                padding: const EdgeInsets.all(TaaevonDimensions.lg),
                children: [
                  _SettingCard(
                    title: 'Daily goal',
                    subtitle: 'Activities to complete each day',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StepButton(
                          label: '−',
                          onTap: s.dailyGoal > SettingsCubit.minGoal
                              ? () => cubit.setDailyGoal(s.dailyGoal - 1)
                              : null,
                        ),
                        Text(
                          '${s.dailyGoal}',
                          style: TaaevonTypography.heading.copyWith(
                            fontFamily: TaaevonTypography.fontFamilyMono,
                            fontSize: 26,
                          ),
                        ),
                        _StepButton(
                          label: '+',
                          onTap: s.dailyGoal < SettingsCubit.maxGoal
                              ? () => cubit.setDailyGoal(s.dailyGoal + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TaaevonDimensions.md),
                  _SettingCard(
                    title: 'Reduce motion',
                    subtitle: 'Skip non-essential animations, like the polygon shake',
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: s.reduceMotion,
                        activeColor: TaaevonColors.secondaryAction,
                        onChanged: cubit.setReduceMotion,
                      ),
                    ),
                  ),
                  const SizedBox(height: TaaevonDimensions.lg),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutScreen(),
                        ),
                      ),
                      child: const Text('About Taaevon'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      decoration: BoxDecoration(
        color: TaaevonColors.cardBackground,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
        border: Border.all(color: TaaevonColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TaaevonTypography.heading.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(subtitle, style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.md),
          child,
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label == '+' ? 'Increase daily goal' : 'Decrease daily goal',
      child: Material(
        color: enabled ? TaaevonColors.primaryAction : TaaevonColors.disabled,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
