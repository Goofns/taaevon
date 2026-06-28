import '../domain/fact_entity.dart';
import 'fact_local_datasource.dart';

/// Repository boundary for the fact engine. Returns plain entities/lists; the
/// use case owns selection randomness and the latency contract.
class FactRepository {
  FactRepository({required FactLocalDataSource local}) : _local = local;

  final FactLocalDataSource _local;

  Future<List<FactEntity>> eligibleFacts({
    required int complexityMax,
    required Set<String> excludeIds,
  }) {
    return _local.eligibleFacts(
      complexityMax: complexityMax,
      excludeIds: excludeIds,
    );
  }

  Future<void> warmUp() => _local.ensureLoaded();

  int get totalCount => _local.totalCount;
}
