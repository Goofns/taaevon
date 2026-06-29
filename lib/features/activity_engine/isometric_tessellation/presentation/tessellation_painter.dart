import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../domain/tessellation_board.dart';

/// Draws the tessellation panel: empty cells as faint outlines, filled cells as
/// two-facet geometric tiles (a diagonal split gives the isometric look). Pure
/// geometry — no characters.
class TessellationPainter extends CustomPainter {
  const TessellationPainter({
    required this.filled,
    required this.rows,
    required this.cols,
  });

  final Set<Cell> filled;
  final int rows;
  final int cols;

  double cellSize(Size size) => size.shortestSide / (rows > cols ? rows : cols);

  @override
  void paint(Canvas canvas, Size size) {
    final s = cellSize(size);

    final outline = Paint()
      ..color = TaaevonColors.mathAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final facetA = Paint()..color = TaaevonColors.accentC;
    final facetB = Paint()..color = TaaevonColors.accentA;
    final edge = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(c * s, r * s, s, s);
        if (filled.contains(Cell(r, c))) {
          // Two triangular facets split along the diagonal.
          final tl = rect.topLeft, tr = rect.topRight;
          final br = rect.bottomRight, bl = rect.bottomLeft;
          canvas.drawPath(
            Path()..addPolygon([tl, tr, br], true),
            facetA,
          );
          canvas.drawPath(
            Path()..addPolygon([tl, br, bl], true),
            facetB,
          );
          canvas.drawRect(rect.deflate(0.75), edge);
        } else {
          canvas.drawRect(rect.deflate(1), outline);
        }
      }
    }
  }

  @override
  bool shouldRepaint(TessellationPainter old) =>
      old.filled.length != filled.length ||
      old.rows != rows ||
      old.cols != cols;
}
