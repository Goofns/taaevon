import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../fact_engine/bloc/fact_bloc.dart';
import '../../fact_engine/presentation/fact_interstitial_widget.dart';
import '../../fact_engine/presentation/fact_route.dart';
import '../../language/presentation/language_selection_screen.dart';
import '../../math/presentation/math_domain_matrix_screen.dart';
import '../../progress/cubit/progress_cubit.dart';
import '../../progress/presentation/stats_screen.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/presentation/settings_screen.dart';

/// Module-selection home screen. Demonstrates the geometric background, the two
/// curriculum tracks, and the micro-learning fact interstitial.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userId = 'demo-user'});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final seed = BackgroundSeedGenerator.fromUserId(userId);

    return Scaffold(
      body: GeometricBackground(
        seed: seed,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: TaaevonColors.secondaryText),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TaaevonDimensions.sm),
                const Center(child: Text('TAAEVON', style: TaaevonTypography.display)),
                const SizedBox(height: TaaevonDimensions.xs),
                const Center(
                  child: Text(
                    'Mathematics  ·  Language',
                    style: TaaevonTypography.label,
                  ),
                ),
                const SizedBox(height: TaaevonDimensions.xxl),
                Row(
                  children: [
                    Expanded(
                      child: _TrackCard(
                        title: 'MATHEMATICS',
                        subtitle: 'Pick a domain',
                        accent: TaaevonColors.mathAccent,
                        glyph: _MathGlyph(),
                        onTap: () => pushWithFact<void>(
                          context,
                          const MathDomainMatrixScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: TaaevonDimensions.md),
                    Expanded(
                      child: _TrackCard(
                        title: 'LANGUAGE',
                        subtitle: 'Choose a language',
                        // accentB (#1B5299, 7.44:1 on the card) instead of the
                        // brighter languageAccent (#0D6EFD, 4.33:1 — fails AA for
                        // this 16px title). Only the title text uses `accent`.
                        accent: TaaevonColors.accentB,
                        glyph: _LanguageGlyph(),
                        onTap: () => pushWithFact<void>(
                          context,
                          const LanguageSelectionScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TaaevonDimensions.xl),
                const _DailyGoal(),
                const Spacer(),
                // Live micro-learning interstitial.
                const FactInterstitial(),
                const SizedBox(height: TaaevonDimensions.md),
                ElevatedButton(
                  onPressed: () => context
                      .read<FactBloc>()
                      .add(const FactRequested(complexityLevel: 5)),
                  child: const Text('Show a fact'),
                ),
                const SizedBox(height: TaaevonDimensions.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal();

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<SettingsCubit>().state.dailyGoal;
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, p) {
        return Semantics(
          button: true,
          label:
              'Daily goal, ${p.total} of $goal complete. Open progress details',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily goal', style: TaaevonTypography.label),
                Text('${p.total} / $goal', style: TaaevonTypography.label),
              ],
            ),
            const SizedBox(height: TaaevonDimensions.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: TaaevonDimensions.progressHeight,
                child: Stack(
                  children: [
                    Container(color: TaaevonColors.backgroundDeep),
                    FractionallySizedBox(
                      widthFactor: p.progressToward(goal),
                      child: Container(color: TaaevonColors.languageAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
        );
      },
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.glyph,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title track, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
          child: Container(
            height: 168,
            padding: const EdgeInsets.all(TaaevonDimensions.md),
            decoration: BoxDecoration(
              color: TaaevonColors.cardBackground,
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
              border: Border.all(color: TaaevonColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Center(child: glyph)),
                Text(
                  title,
                  style: TaaevonTypography.heading
                      .copyWith(color: accent, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TaaevonTypography.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pure-geometry glyph for the Mathematics track (no characters/faces).
class _MathGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(56, 56),
        painter: _PolyPainter(sides: 3, color: TaaevonColors.mathAccent),
      );
}

/// Pure-geometry glyph for the Language track.
class _LanguageGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(56, 56),
        painter: _PolyPainter(sides: 6, color: TaaevonColors.languageAccent),
      );
}

class _PolyPainter extends CustomPainter {
  const _PolyPainter({required this.sides, required this.color});
  final int sides;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = (2 * 3.1415926535 * i / sides) - 3.1415926535 / 2;
      final p = center + Offset.fromDirection(angle, radius);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PolyPainter oldDelegate) =>
      oldDelegate.sides != sides || oldDelegate.color != color;
}
