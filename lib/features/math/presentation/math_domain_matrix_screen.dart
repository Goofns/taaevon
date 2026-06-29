import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../activity_engine/isometric_tessellation/presentation/isometric_tessellation_screen.dart';
import '../../activity_engine/matrix_vector_track/presentation/matrix_vector_track_screen.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../sync_engine/dynamic_difficulty_calibrator.dart';
import '../domain/math_domain.dart';
import 'math_screen.dart';

/// Category-based math domain selection matrix (PRD §7.2). Each domain is a
/// geometric tile; tapping an unlocked one opens the live problem screen at that
/// domain's band. No linear path is forced — any unlocked domain is selectable.
class MathDomainMatrixScreen extends StatelessWidget {
  const MathDomainMatrixScreen({super.key, this.targetLanguage = 'ja'});

  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MATHEMATICS', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('math-matrix'),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tier in const [1, 2, 3]) ...[
                  Text(
                    'TIER $tier · ${MathDomainCatalog.tierLabels[tier]!.toUpperCase()}',
                    style: TaaevonTypography.label,
                  ),
                  const SizedBox(height: TaaevonDimensions.sm),
                  Wrap(
                    spacing: TaaevonDimensions.md,
                    runSpacing: TaaevonDimensions.md,
                    children: [
                      for (final domain in MathDomainCatalog.forTier(tier))
                        _DomainTile(
                          domain: domain,
                          onTap: domain.unlocked
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => MathScreen(
                                        band: domain.band,
                                        cefr: CefrLevel.a1,
                                        targetLanguage: targetLanguage,
                                      ),
                                    ),
                                  )
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: TaaevonDimensions.lg),
                ],
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IsometricTessellationScreen(),
                    ),
                  ),
                  child: const Text('Isometric Tessellation challenge'),
                ),
                const SizedBox(height: TaaevonDimensions.sm),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MatrixVectorTrackScreen(),
                    ),
                  ),
                  child: const Text('Matrix Vector Track'),
                ),
                const SizedBox(height: TaaevonDimensions.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.domain, this.onTap});

  final MathDomain domain;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !domain.unlocked;
    final opacity = locked ? 0.4 : 1.0;

    return Semantics(
      button: !locked,
      label: locked
          ? '${domain.name}, locked'
          : '${domain.name}, ${(domain.completion * 100).round()} percent complete',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 152,
              height: 160,
              padding: const EdgeInsets.all(TaaevonDimensions.md),
              decoration: BoxDecoration(
                color: TaaevonColors.cardBackground,
                borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
                border: Border.all(color: TaaevonColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: CustomPaint(
                        size: const Size(48, 48),
                        painter: locked
                            ? const _LockGlyphPainter()
                            : _PolygonGlyphPainter(sides: domain.glyphSides),
                      ),
                    ),
                  ),
                  Text(
                    domain.name,
                    style: TaaevonTypography.heading.copyWith(
                      fontSize: 15,
                      color: TaaevonColors.mathAccent,
                    ),
                  ),
                  const SizedBox(height: TaaevonDimensions.sm),
                  _CompletionBar(value: domain.completion),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            Container(color: TaaevonColors.backgroundDeep),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(color: TaaevonColors.mathAccent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outline polygon glyph (pure geometry, no characters).
class _PolygonGlyphPainter extends CustomPainter {
  const _PolygonGlyphPainter({required this.sides});
  final int sides;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..color = TaaevonColors.mathAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final points = <Offset>[
      for (var i = 0; i < sides; i++)
        center +
            Offset.fromDirection(
              (2 * math.pi * i / sides) - math.pi / 2,
              radius,
            ),
    ];
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }

  @override
  bool shouldRepaint(_PolygonGlyphPainter old) => old.sides != sides;
}

/// Lock glyph rendered as two nested squares (no padlock iconography).
class _LockGlyphPainter extends CustomPainter {
  const _LockGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // secondaryText (not disabled #8FA6B5 = 2.44:1) so the lock glyph meets
      // the 3:1 UI-component contrast threshold on the card tile.
      ..color = TaaevonColors.secondaryText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final c = size.center(Offset.zero);
    for (final half in [size.shortestSide / 2, size.shortestSide / 4]) {
      canvas.drawRect(
        Rect.fromCenter(
            center: c, width: half * 2 * 0.8, height: half * 2 * 0.8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LockGlyphPainter old) => false;
}
