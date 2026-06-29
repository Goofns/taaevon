import '../domain/lexicon_entry.dart';
import 'lexicon_local_datasource.dart';

/// Repository boundary for the universal lexicon.
class LexiconRepository {
  LexiconRepository({required LexiconLocalDataSource local}) : _local = local;

  /// The default production repository (bundled-asset datasource). Screens use
  /// this as the fallback when no repository is injected for testing.
  factory LexiconRepository.production() =>
      LexiconRepository(local: LexiconLocalDataSource());

  final LexiconLocalDataSource _local;

  Future<List<LexiconEntry>> all() => _local.all();

  /// All entries translating INTO [targetLanguage] (e.g. 'ja', 'es').
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async {
    final all = await _local.all();
    return all.where((e) => e.targetLanguage == targetLanguage).toList();
  }
}
