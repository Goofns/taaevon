import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/math/domain/math_domain.dart';

void main() {
  group('MathDomainCatalog', () {
    test('exposes three domains per tier across three tiers', () {
      for (final tier in [1, 2, 3]) {
        expect(
          MathDomainCatalog.forTier(tier),
          hasLength(3),
          reason: 'tier $tier',
        );
        expect(MathDomainCatalog.tierLabels.containsKey(tier), isTrue);
      }
    });

    test('every domain band falls inside its tier range', () {
      for (final d in MathDomainCatalog.domains) {
        switch (d.tier) {
          case 1:
            expect(d.band, lessThan(2.0), reason: d.id);
          case 2:
            expect(d.band, inInclusiveRange(2.0, 2.999), reason: d.id);
          case 3:
            expect(d.band, greaterThanOrEqualTo(3.0), reason: d.id);
        }
        expect(d.band, lessThanOrEqualTo(3.99));
        expect(d.completion, inInclusiveRange(0.0, 1.0));
        expect(d.glyphSides, greaterThanOrEqualTo(3));
      }
    });

    test('at least one unlocked domain exists per tier for navigation', () {
      for (final tier in [1, 2, 3]) {
        expect(
          MathDomainCatalog.forTier(tier).any((d) => d.unlocked),
          isTrue,
          reason: 'tier $tier needs an entry point',
        );
      }
    });
  });
}
