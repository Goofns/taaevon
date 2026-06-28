import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/isometric_tessellation/domain/tessellation_board.dart';

void main() {
  group('TessellationBoard', () {
    test('first tile may be placed on any in-bounds cell', () {
      expect(TessellationBoard.canPlace({}, const Cell(1, 1), 3, 3), isTrue);
      expect(TessellationBoard.canPlace({}, const Cell(3, 0), 3, 3), isFalse);
      expect(TessellationBoard.canPlace({}, const Cell(-1, 0), 3, 3), isFalse);
    });

    test('subsequent tiles must be 4-adjacent to the pattern', () {
      final filled = {const Cell(0, 0)};
      expect(TessellationBoard.canPlace(filled, const Cell(0, 1), 3, 3), isTrue);
      expect(TessellationBoard.canPlace(filled, const Cell(1, 0), 3, 3), isTrue);
      // diagonal is not 4-connected
      expect(TessellationBoard.canPlace(filled, const Cell(1, 1), 3, 3), isFalse);
      // already occupied
      expect(TessellationBoard.canPlace(filled, const Cell(0, 0), 3, 3), isFalse);
      // detached from the pattern
      expect(TessellationBoard.canPlace(filled, const Cell(2, 2), 3, 3), isFalse);
    });

    test('isFull when every cell is placed', () {
      final filled = {
        for (var r = 0; r < 2; r++)
          for (var c = 0; c < 2; c++) Cell(r, c),
      };
      expect(TessellationBoard.isFull(filled, 2, 2), isTrue);
      expect(TessellationBoard.isFull({const Cell(0, 0)}, 2, 2), isFalse);
    });
  });
}
