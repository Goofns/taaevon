import 'dart:math';

import '../data/fact_repository.dart';
import 'fact_entity.dart';

/// Result of a fact request. [FactExhausted] means every eligible fact has
/// already been shown this session.
sealed class FactResult {
  const FactResult();
}

class FactSuccess extends FactResult {
  const FactSuccess(this.fact);
  final FactEntity fact;
}

class FactExhausted extends FactResult {
  const FactExhausted();
}

class FactFailed extends FactResult {
  const FactFailed(this.message);
  final String message;
}

/// Selects a unique random fact within the user's complexity profile.
///
/// Latency contract (PRD §6.2): the in-memory path resolves in well under the
/// 50 ms budget. A debug assertion flags any regression.
class GetRandomFactUseCase {
  GetRandomFactUseCase({required FactRepository repository, Random? random})
      : _repository = repository,
        _rng = random ?? Random.secure();

  final FactRepository _repository;
  final Random _rng;

  Future<FactResult> call({
    required int complexityLevel,
    required Set<String> excludeIds,
  }) async {
    final watch = Stopwatch()..start();
    try {
      final eligible = await _repository.eligibleFacts(
        complexityMax: complexityLevel,
        excludeIds: excludeIds,
      );
      if (eligible.isEmpty) return const FactExhausted();

      final fact = eligible[_rng.nextInt(eligible.length)];
      watch.stop();
      assert(
        watch.elapsedMilliseconds < 50,
        'Fact retrieval exceeded 50ms budget: ${watch.elapsedMilliseconds}ms',
      );
      return FactSuccess(fact);
    } catch (e) {
      return FactFailed(e.toString());
    }
  }

  Future<void> warmUp() => _repository.warmUp();
}
