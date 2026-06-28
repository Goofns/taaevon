import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/background/background_seed_generator.dart';

void main() {
  group('BackgroundSeedGenerator', () {
    test('is deterministic for a given id', () {
      expect(
        BackgroundSeedGenerator.fromUserId('alice'),
        BackgroundSeedGenerator.fromUserId('alice'),
      );
    });

    test('different ids produce different seeds', () {
      expect(
        BackgroundSeedGenerator.fromUserId('alice') ==
            BackgroundSeedGenerator.fromUserId('bob'),
        isFalse,
      );
    });

    test('anonymous seed is stable', () {
      expect(
        BackgroundSeedGenerator.anonymous,
        BackgroundSeedGenerator.fromUserId('taaevon-anonymous'),
      );
    });

    test('seed stays within the 32-bit range', () {
      final seed = BackgroundSeedGenerator.fromUserId('some-user-id');
      expect(seed, greaterThanOrEqualTo(0));
      expect(seed, lessThanOrEqualTo(0xFFFFFFFF));
    });
  });
}
