import 'package:equatable/equatable.dart';

enum VectorDirection { up, down, left, right }

/// A node coordinate (row, col) on the vector grid.
class VectorPos extends Equatable {
  const VectorPos(this.row, this.col);
  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];
}

/// Pure navigation rules for the Matrix Vector Track (PRD §9.3). Movement is
/// clamped to the grid; the goal is to land the vector head on the target node.
abstract class VectorTrackRules {
  static int _clamp(int v, int size) => v < 0 ? 0 : (v >= size ? size - 1 : v);

  static VectorPos move(VectorPos p, VectorDirection d, int size) {
    switch (d) {
      case VectorDirection.up:
        return VectorPos(_clamp(p.row - 1, size), p.col);
      case VectorDirection.down:
        return VectorPos(_clamp(p.row + 1, size), p.col);
      case VectorDirection.left:
        return VectorPos(p.row, _clamp(p.col - 1, size));
      case VectorDirection.right:
        return VectorPos(p.row, _clamp(p.col + 1, size));
    }
  }

  static bool atTarget(VectorPos cur, VectorPos target) => cur == target;
}
