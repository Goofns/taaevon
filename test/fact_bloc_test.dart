import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/fact_engine/bloc/fact_bloc.dart';
import 'package:taaevon/features/fact_engine/data/fact_repository.dart';
import 'package:taaevon/features/fact_engine/domain/fact_entity.dart';
import 'package:taaevon/features/fact_engine/domain/get_random_fact_usecase.dart';

/// A repository stub backed by an in-memory list (no asset bundle needed).
class _StubRepository implements FactRepository {
  _StubRepository(this._all);
  final List<FactEntity> _all;

  @override
  Future<List<FactEntity>> eligibleFacts({
    required int complexityMax,
    required Set<String> excludeIds,
  }) async {
    return _all
        .where((f) =>
            f.complexityRating <= complexityMax &&
            !excludeIds.contains(f.factId))
        .toList();
  }

  @override
  Future<void> warmUp() async {}

  @override
  int get totalCount => _all.length;
}

FactEntity _fact(String id, int complexity) => FactEntity(
      factId: id,
      category: 'Mathematics & Logic',
      content: 'Fact $id',
      complexityRating: complexity,
      verificationSource: 'https://example.org',
    );

void main() {
  group('FactBloc', () {
    test('never repeats a fact within a session, then depletes', () async {
      final repo = _StubRepository([
        _fact('a', 1),
        _fact('b', 2),
        _fact('c', 3),
      ]);
      final bloc = FactBloc(
        getRandomFact: GetRandomFactUseCase(
          repository: repo,
          random: Random(42), // deterministic
        ),
      );

      final seen = <String>{};
      for (var i = 0; i < 3; i++) {
        bloc.add(const FactRequested(complexityLevel: 5));
        final state = await bloc.stream.firstWhere((s) => s is! FactLoading);
        expect(state, isA<FactReady>());
        seen.add((state as FactReady).fact.factId);
      }
      expect(seen, {'a', 'b', 'c'});

      // Fourth request exhausts the pool.
      bloc.add(const FactRequested(complexityLevel: 5));
      final depleted = await bloc.stream.firstWhere((s) => s is! FactLoading);
      expect(depleted, isA<FactDepleted>());

      await bloc.close();
    });

    test('respects the complexity ceiling', () async {
      final repo = _StubRepository([_fact('hard', 5), _fact('easy', 1)]);
      final bloc = FactBloc(
        getRandomFact: GetRandomFactUseCase(repository: repo, random: Random(1)),
      );

      bloc.add(const FactRequested(complexityLevel: 2));
      final state = await bloc.stream.firstWhere((s) => s is! FactLoading);
      expect((state as FactReady).fact.factId, 'easy');

      await bloc.close();
    });
  });
}
