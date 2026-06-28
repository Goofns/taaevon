import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Renders the static three-layer geometric background:
///   1. 60-degree isometric grid
///   2. low-opacity polygon field (avoids the central safe zone)
///   3. soft radial depth accents
///
/// The composition is deterministic for a given [seedValue] and is intended to
/// be wrapped in a [RepaintBoundary] — it must not repaint from business logic.
class GeometricBackgroundPainter extends CustomPainter {
  const GeometricBackgroundPainter({required this.seedValue});

  final int seedValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawIsometricGrid(canvas, size);
    _drawPolygonField(canvas, size);
    _drawDepthAccents(canvas, size);
  }

  void _drawIsometricGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TaaevonColors.gridLine.withOpacity(0.12)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = TaaevonDimensions.gridSpacing;
    final dx = size.height / math.tan(math.pi / 3); // horizontal run of a 60° line

    // Horizontal rows
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Left-leaning 60° lines
    for (double x = -dx; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + dx, size.height), paint);
    }
    // Right-leaning 120° lines
    for (double x = 0; x <= size.width + dx; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x - dx, size.height), paint);
    }
  }

  void _drawPolygonField(Canvas canvas, Size size) {
    final rng = math.Random(seedValue);
    final paint = Paint()
      ..color = TaaevonColors.polygonFill.withOpacity(0.09)
      ..style = PaintingStyle.fill;

    // Central 60% is a no-draw "safe zone" so foreground content stays clean.
    final safe = Rect.fromLTWH(
      size.width * 0.20,
      size.height * 0.20,
      size.width * 0.60,
      size.height * 0.60,
    );

    final polygonCount = 8 + rng.nextInt(7); // 8–14
    for (var i = 0; i < polygonCount; i++) {
      final center = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      if (safe.contains(center)) continue;

      final radius = 40 + rng.nextDouble() * 140; // 40–180dp
      final vertexCount = 5 + rng.nextInt(4); // 5–8

      final path = Path();
      for (var v = 0; v < vertexCount; v++) {
        final angle = (2 * math.pi * v / vertexCount) - math.pi / 2;
        final jitter = 0.7 + rng.nextDouble() * 0.6;
        final point = center +
            Offset(math.cos(angle), math.sin(angle)) * (radius * jitter);
        v == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawDepthAccents(Canvas canvas, Size size) {
    final rng = math.Random(seedValue + 1);
    final anchors = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
      Offset(size.width / 2, size.height / 2),
    ];

    final count = 3 + rng.nextInt(3); // 3–5
    for (var i = 0; i < count; i++) {
      final center = anchors[i % anchors.length];
      final radius = 100 + rng.nextDouble() * 200;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            TaaevonColors.polygonFill.withOpacity(0.09),
            TaaevonColors.polygonFill.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(GeometricBackgroundPainter oldDelegate) =>
      oldDelegate.seedValue != seedValue;
}

/// Convenience wrapper that stacks the (cached) background behind [child].
class GeometricBackground extends StatelessWidget {
  const GeometricBackground({
    super.key,
    required this.seed,
    required this.child,
  });

  final int seed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(seedValue: seed),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
