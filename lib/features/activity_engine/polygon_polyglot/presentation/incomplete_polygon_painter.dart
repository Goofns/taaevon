import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

/// Draws a regular polygon with [totalVertices] positions, of which the first
/// [placedVertices] are "locked" (filled, edges drawn). Remaining vertices are
/// faint ghost markers. When [complete] the polygon fills with a soft gradient.
/// Pure geometry — no characters, faces, or icons.
class IncompletePolygonPainter extends CustomPainter {
  const IncompletePolygonPainter({
    required this.placedVertices,
    required this.totalVertices,
    required this.complete,
    this.accent = TaaevonColors.languageAccent,
  });

  final int placedVertices;
  final int totalVertices;
  final bool complete;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 16;
    final points = <Offset>[
      for (var i = 0; i < totalVertices; i++)
        center +
            Offset.fromDirection(
              (2 * math.pi * i / totalVertices) - math.pi / 2,
              radius,
            ),
    ];

    // Ghost outline of the full target polygon.
    final ghost = Paint()
      ..color = accent.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final ghostPath = Path()..addPolygon(points, true);
    canvas.drawPath(ghostPath, ghost);

    // Filled body once solved.
    if (complete) {
      final fill = Paint()
        ..shader = RadialGradient(
          colors: [accent.withOpacity(0.35), accent.withOpacity(0.10)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(Path()..addPolygon(points, true), fill);
    }

    // Locked edges connecting consecutive placed vertices.
    final edge = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    if (placedVertices >= 2) {
      final locked = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < placedVertices; i++) {
        locked.lineTo(points[i].dx, points[i].dy);
      }
      if (complete) locked.close();
      canvas.drawPath(locked, edge);
    }

    // Vertex markers.
    for (var i = 0; i < totalVertices; i++) {
      final placed = i < placedVertices;
      final marker = Paint()
        ..style = placed ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = placed ? accent : accent.withOpacity(0.30);
      canvas.drawCircle(points[i], placed ? 7 : 5, marker);
    }
  }

  @override
  bool shouldRepaint(IncompletePolygonPainter old) =>
      old.placedVertices != placedVertices ||
      old.totalVertices != totalVertices ||
      old.complete != complete ||
      old.accent != accent;
}
