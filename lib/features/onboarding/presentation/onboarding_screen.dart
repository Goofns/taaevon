import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../settings/cubit/settings_cubit.dart';

/// One-time first-run intro. Completing it sets the persisted `onboardingSeen`
/// flag, after which the root gate shows the home screen.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('onboarding'),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TaaevonDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Center(
                  child: Text('TAAEVON', style: TaaevonTypography.display),
                ),
                const SizedBox(height: TaaevonDimensions.xl),
                const Center(
                  child: CustomPaint(
                    size: Size(120, 120),
                    painter: _OnboardGlyphPainter(),
                  ),
                ),
                const SizedBox(height: TaaevonDimensions.xl),
                const Text(
                  'Two minds, one path.\n\n'
                  'Learn mathematics and language together — from first counting to '
                  'advanced calculus, from your first word to fluent conversation. '
                  'No characters, no clutter: just pure geometry and ideas.',
                  textAlign: TextAlign.center,
                  style: TaaevonTypography.body,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      context.read<SettingsCubit>().completeOnboarding(),
                  child: const Text('Get started'),
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

/// Two interlocking polygons — a triangle (mathematics) over a hexagon
/// (language) — expressing the dual curriculum in pure geometry.
class _OnboardGlyphPainter extends CustomPainter {
  const _OnboardGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;

    void poly(int sides, Color color, double rotation) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round;
      final points = <Offset>[
        for (var i = 0; i < sides; i++)
          center +
              Offset.fromDirection(
                (2 * math.pi * i / sides) - math.pi / 2 + rotation,
                r,
              ),
      ];
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }

    poly(6, TaaevonColors.languageAccent, 0); // hexagon
    poly(3, TaaevonColors.mathAccent, 0); // triangle
  }

  @override
  bool shouldRepaint(_OnboardGlyphPainter oldDelegate) => false;
}
