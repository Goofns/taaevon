import '../domain/lexicon_entry.dart';
import 'lexicon_local_datasource.dart';

/// Repository boundary for the universal lexicon.
class LexiconRepository {
  LexiconRepository({required LexiconLocalDataSource local}) : _local = local;

  final LexiconLocalDataSource _local;

  Future<List<LexiconEntry>> all() => _local.all();

  /// All entries translating INTO [targetLanguage] (e.g. 'ja', 'es').
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async {
    final all = await _local.all();
    return all.where((e) => e.targetLanguage == targetLanguage).toList();
  }
}
