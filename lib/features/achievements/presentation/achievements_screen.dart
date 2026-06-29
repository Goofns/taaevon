import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../progress/cubit/progress_cubit.dart';
import '../../streak/cubit/streak_cubit.dart';
import '../domain/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ACHIEVEMENTS', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('achievements'),
        child: SafeArea(
          child: BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, p) {
              final streak = context.watch<StreakCubit>().state.count;
              final snap = AchievementSnapshot(
                totalCompletions: p.total,
                streak: streak,
                polyglot: p.completionsOf(ActivityIds.polyglot),
                tessellation: p.completionsOf(ActivityIds.tessellation),
                vector: p.completionsOf(ActivityIds.vector),
              );
              final unlocked = AchievementCatalog.unlockedCount(snap);
              return ListView(
                padding: const EdgeInsets.all(TaaevonDimensions.lg),
                children: [
                  Text(
                    '$unlocked / ${AchievementCatalog.all.length} unlocked',
                    style: TaaevonTypography.label,
                  ),
                  const SizedBox(height: TaaevonDimensions.md),
                  for (final a in AchievementCatalog.all)
                    _AchievementTile(
                      achievement: a,
                      value: snap.value(a.metric),
                      unlocked: AchievementCatalog.isUnlocked(a, snap),
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

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.value,
    required this.unlocked,
  });

  final Achievement achievement;
  final int value;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final progress = (value / achievement.threshold).clamp(0.0, 1.0);
    return Opacity(
      opacity: unlocked ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: TaaevonDimensions.sm),
        padding: const EdgeInsets.all(TaaevonDimensions.md),
        decoration: BoxDecoration(
          color: TaaevonColors.cardBackground,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
          border: Border.all(
            color: unlocked ? TaaevonColors.success : TaaevonColors.cardBorder,
            width: unlocked ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPaint(
              size: const Size(40, 40),
              painter: _BadgePainter(unlocked: unlocked),
            ),
            const SizedBox(width: TaaevonDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TaaevonTypography.heading.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(achievement.description, style: TaaevonTypography.label),
                  if (!unlocked) ...[
                    const SizedBox(height: TaaevonDimensions.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 5,
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
                    const SizedBox(height: 2),
                    Text('$value / ${achievement.threshold}',
                        style: TaaevonTypography.label),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hexagonal badge glyph — filled when unlocked, faint outline when locked.
class _BadgePainter extends CustomPainter {
  const _BadgePainter({required this.unlocked});
  final bool unlocked;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    final points = <Offset>[
      for (var i = 0; i < 6; i++)
        center + Offset.fromDirection((2 * math.pi * i / 6) - math.pi / 2, r),
    ];
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(
      path,
      Paint()
        ..color = unlocked
            ? TaaevonColors.success.withOpacity(0.25)
            : TaaevonColors.backgroundDeep,
    );
    canvas.drawPath(
      path,
      Paint()
        // secondaryText for the locked stroke: disabled (#8FA6B5) over the
        // backgroundDeep fill is only 1.98:1, failing the 3:1 UI threshold.
        ..color = unlocked ? TaaevonColors.success : TaaevonColors.secondaryText
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.unlocked != unlocked;
}
