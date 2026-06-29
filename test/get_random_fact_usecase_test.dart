import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/fact_engine/data/fact_repository.dart';
import 'package:taaevon/features/fact_engine/domain/fact_entity.dart';
import 'package:taaevon/features/fact_engine/domain/get_random_fact_usecase.dart';

class _StubFactRepo implements FactRepository {
  _StubFactRepo(this._facts);
  final List<FactEntity> _facts;

  @override
  Future<List<FactEntity>> eligibleFacts({
    required int complexityMax,
    required Set<String> excludeIds,
  }) async =>
      _facts
          .where(
            (f) =>
                f.complexityRating <= complexityMax &&
                !excludeIds.contains(f.factId),
          )
          .toList();

  @override
  Future<void> warmUp() async {}

  @override
  int get totalCount => _facts.length;
}

FactEntity _fact(String id, int complexity) => FactEntity(
      factId: id,
      category: 'Mathematics & Logic',
      content: 'Fact $id',
      complexityRating: complexity,
      verificationSource: 'https://example.org',
    );

void main() {
  group('GetRandomFactUseCase', () {
    test('returns a fact at or below the complexity ceiling', () async {
      final useCase = GetRandomFactUseCase(
        repository: _StubFactRepo([_fact('easy', 1), _fact('hard', 5)]),
        random: Random(1),
      );
      final result = await useCase(complexityLevel: 2, excludeIds: {});
      expect(result, isA<FactSuccess>());
      expect((result as FactSuccess).fact.factId, 'easy');
    });

    test('exhausts when every eligible fact is excluded', () async {
      final useCase = GetRandomFactUseCase(
        repository: _StubFactRepo([_fact('a', 1)]),
        random: Random(1),
      );
      final result = await useCase(complexityLevel: 5, excludeIds: {'a'});
      expect(result, isA<FactExhausted>());
    });
  });
}
