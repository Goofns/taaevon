import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../domain/vector_track.dart';

/// Draws the vector grid: faint cells labelled with their column number-word,
/// the target node ringed, and the vector as an arrow from the origin to the
/// current head. Pure geometry plus the vocabulary labels.
class VectorTrackPainter extends CustomPainter {
  const VectorTrackPainter({
    required this.gridSize,
    required this.current,
    required this.target,
    required this.columnWords,
  });

  final int gridSize;
  final VectorPos current;
  final VectorPos target;
  final Map<int, String> columnWords;

  Offset _center(VectorPos p, double cs) =>
      Offset(p.col * cs + cs / 2, p.row * cs + cs / 2);

  @override
  void paint(Canvas canvas, Size size) {
    final cs = size.shortestSide / gridSize;

    final cell = Paint()
      ..color = TaaevonColors.languageAccent.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        final rect = Rect.fromLTWH(c * cs, r * cs, cs, cs).deflate(2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          cell,
        );
        _label(
          canvas,
          columnWords[c] ?? '${c + 1}',
          Offset(c * cs + cs / 2, r * cs + cs * 0.28),
        );
      }
    }

    // Target node ring.
    final ring = Paint()
      ..color = TaaevonColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(_center(target, cs), cs * 0.30, ring);

    // Vector from origin (0,0) to current head.
    final origin = _center(const VectorPos(0, 0), cs);
    final head = _center(current, cs);
    final vector = Paint()
      ..color = TaaevonColors.primaryAction
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(origin, 4, Paint()..color = TaaevonColors.primaryAction);
    if (head != origin) {
      canvas.drawLine(origin, head, vector);
      _arrowHead(canvas, origin, head, vector);
    }
    canvas.drawCircle(
      head,
      7,
      Paint()..color = TaaevonColors.primaryAction,
    );
  }

  void _arrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = (to - from).direction;
    const wing = 12.0;
    const spread = math.pi / 7;
    final p1 = to - Offset.fromDirection(angle - spread, wing);
    final p2 = to - Offset.fromDirection(angle + spread, wing);
    canvas.drawLine(to, p1, paint);
    canvas.drawLine(to, p2, paint);
  }

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: TaaevonColors.secondaryText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(VectorTrackPainter old) =>
      old.current != current ||
      old.target != target ||
      old.gridSize != gridSize;
}
