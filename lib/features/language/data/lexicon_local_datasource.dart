import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/lexicon_entry.dart';

/// Loads the bundled lexicon JSON ({"languages": [...], "words": [...]}) into
/// memory as [LexiconEntry] objects. Production swaps this for a sqflite source
/// over the bundled `taaevon.db` (see PRD §11.3).
class LexiconLocalDataSource {
  LexiconLocalDataSource({this.assetPath = 'assets/data/lexicon_seed.json'});

  final String assetPath;
  List<LexiconEntry> _entries = const [];
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    final map = json.decode(raw) as Map<String, dynamic>;
    final words = (map['words'] as List<dynamic>);
    _entries = [
      for (var i = 0; i < words.length; i++)
        LexiconEntry.fromJson(words[i] as Map<String, dynamic>, 'lex-$i'),
    ];
    _loaded = true;
  }

  Future<List<LexiconEntry>> all() async {
    await ensureLoaded();
    return _entries;
  }
}
