import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';

/// Shared test stub for [LexiconRepository] — serves a fixed entry list and
/// filters by target language. Each test supplies its own LexiconEntry fixtures.
class StubLexiconRepo implements LexiconRepository {
  StubLexiconRepo(this._entries);
  final List<LexiconEntry> _entries;

  @override
  Future<List<LexiconEntry>> all() async => _entries;

  @override
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async =>
      _entries.where((e) => e.targetLanguage == targetLanguage).toList();
}
