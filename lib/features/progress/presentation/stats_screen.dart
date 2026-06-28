import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../streak/cubit/streak_cubit.dart';
import '../cubit/progress_cubit.dart';

const Map<String, String> _activityNames = {
  ActivityIds.polyglot: 'Polygon Polyglot',
  ActivityIds.tessellation: 'Isometric Tessellation',
  ActivityIds.vector: 'Matrix Vector Track',
};

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('YOUR PROGRESS', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('stats'),
        child: SafeArea(
          child: BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, p) {
              final goal = context.watch<SettingsCubit>().state.dailyGoal;
              final streak = context.watch<StreakCubit>().state.count;
              final ids = _activityNames.keys.toList();
              final maxCount =
                  ids.map(p.completionsOf).fold<int>(0, (m, c) => c > m ? c : m);
              final mostId = p.mostCompletedActivity;
              return ListView(
                padding: const EdgeInsets.all(TaaevonDimensions.lg),
                children: [
                  _TotalCard(
                    total: p.total,
                    goal: goal,
                    progress: p.progressToward(goal),
                  ),
                  const SizedBox(height: TaaevonDimensions.md),
                  _StreakCard(count: streak),
                  const SizedBox(height: TaaevonDimensions.md),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    ),
                    child: const Text('View achievements'),
                  ),
                  const SizedBox(height: TaaevonDimensions.md),
                  Text('By activity', style: TaaevonTypography.label),
                  const SizedBox(height: TaaevonDimensions.sm),
                  for (final id in ids)
                    _ActivityBar(
                      name: _activityNames[id]!,
                      count: p.completionsOf(id),
                      fraction:
                          maxCount == 0 ? 0 : p.completionsOf(id) / maxCount,
                      highlight: id == mostId && p.completionsOf(id) > 0,
                    ),
                  const SizedBox(height: TaaevonDimensions.lg),
                  if (p.total > 0)
                    Center(
                      child: TextButton(
                        onPressed: () => context.read<ProgressCubit>().reset(),
                        child: const Text('Reset progress'),
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.total,
    required this.goal,
    required this.progress,
  });

  final int total;
  final int goal;
  final double progress;

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
          Text('Total completions', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.xs),
          Text(
            '$total',
            style: TaaevonTypography.display.copyWith(
              fontSize: 40,
              letterSpacing: 0,
              fontFamily: TaaevonTypography.fontFamilyMono,
            ),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          Text('Daily goal: $total / $goal', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: TaaevonDimensions.progressHeight,
              child: Stack(
                children: [
                  Container(color: TaaevonColors.backgroundDeep),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: TaaevonColors.mathAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      decoration: BoxDecoration(
        color: TaaevonColors.cardBackground,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
        border: Border.all(color: TaaevonColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Day streak', style: TaaevonTypography.label),
              const SizedBox(height: 2),
              Text(
                count > 0 ? 'Keep it going!' : 'Practise today to start one',
                style: TaaevonTypography.label,
              ),
            ],
          ),
          Text(
            '$count',
            style: TaaevonTypography.display.copyWith(
              fontSize: 36,
              letterSpacing: 0,
              fontFamily: TaaevonTypography.fontFamilyMono,
              color:
                  count > 0 ? TaaevonColors.success : TaaevonColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.name,
    required this.count,
    required this.fraction,
    required this.highlight,
  });

  final String name;
  final int count;
  final double fraction;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TaaevonDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TaaevonTypography.body.copyWith(fontSize: 14)),
              Text('$count', style: TaaevonTypography.label),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: TaaevonColors.backgroundDeep),
                  FractionallySizedBox(
                    widthFactor: fraction.clamp(0.0, 1.0),
                    child: Container(
                      color: highlight
                          ? TaaevonColors.success
                          : TaaevonColors.languageAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
