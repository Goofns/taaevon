import 'package:equatable/equatable.dart';

/// A cell coordinate on the tessellation board.
class Cell extends Equatable {
  const Cell(this.row, this.col);
  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];
}

/// Pure placement rules for the tessellation panel (PRD §9.4). A tile may be
/// placed on an empty, in-bounds cell that is either the first tile or adjacent
/// (4-connected) to an already-placed tile — so the pattern grows without gaps.
abstract class TessellationBoard {
  static bool inBounds(Cell c, int rows, int cols) =>
      c.row >= 0 && c.row < rows && c.col >= 0 && c.col < cols;

  static List<Cell> neighbors(Cell c) => [
        Cell(c.row - 1, c.col),
        Cell(c.row + 1, c.col),
        Cell(c.row, c.col - 1),
        Cell(c.row, c.col + 1),
      ];

  static bool canPlace(Set<Cell> filled, Cell c, int rows, int cols) {
    if (!inBounds(c, rows, cols)) return false;
    if (filled.contains(c)) return false;
    if (filled.isEmpty) return true;
    return neighbors(c).any(filled.contains);
  }

  static bool isFull(Set<Cell> filled, int rows, int cols) =>
      filled.length >= rows * cols;
}
