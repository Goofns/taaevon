import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/domain/vector_track.dart';

void main() {
  group('VectorTrackRules', () {
    test('movement clamps at the grid edges', () {
      expect(
        VectorTrackRules.move(const VectorPos(0, 0), VectorDirection.up, 3),
        const VectorPos(0, 0),
      );
      expect(
        VectorTrackRules.move(const VectorPos(0, 0), VectorDirection.left, 3),
        const VectorPos(0, 0),
      );
      expect(
        VectorTrackRules.move(const VectorPos(2, 2), VectorDirection.down, 3),
        const VectorPos(2, 2),
      );
      expect(
        VectorTrackRules.move(const VectorPos(2, 2), VectorDirection.right, 3),
        const VectorPos(2, 2),
      );
    });

    test('interior moves shift exactly one cell', () {
      const p = VectorPos(1, 1);
      expect(VectorTrackRules.move(p, VectorDirection.up, 3),
          const VectorPos(0, 1));
      expect(VectorTrackRules.move(p, VectorDirection.down, 3),
          const VectorPos(2, 1));
      expect(VectorTrackRules.move(p, VectorDirection.left, 3),
          const VectorPos(1, 0));
      expect(VectorTrackRules.move(p, VectorDirection.right, 3),
          const VectorPos(1, 2));
    });

    test('atTarget compares coordinates', () {
      expect(
        VectorTrackRules.atTarget(const VectorPos(1, 2), const VectorPos(1, 2)),
        isTrue,
      );
      expect(
        VectorTrackRules.atTarget(const VectorPos(1, 2), const VectorPos(2, 2)),
        isFalse,
      );
    });
  });
}
