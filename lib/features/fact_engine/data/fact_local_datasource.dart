import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import '../domain/fact_entity.dart';

/// Top-level so it can run in a background isolate via [compute]: decodes the
/// facts JSON and maps it to entities off the UI isolate. FactEntity holds only
/// primitive fields, so the result is sendable across the isolate boundary.
List<FactEntity> _parseFacts(String raw) {
  final decoded = json.decode(raw) as List<dynamic>;
  return [
    for (var i = 0; i < decoded.length; i++)
      FactEntity.fromJson(decoded[i] as Map<String, dynamic>, 'seed-$i'),
  ];
}

/// Loads facts from the bundled JSON asset into memory and serves them with a
/// complexity filter and session de-duplication.
///
/// In production this is swapped for a sqflite-backed source reading the
/// bundled `taaevon.db`, with a Hive hot-cache in front of it (see PRD §6).
/// The in-memory implementation keeps the scaffold runnable with no native DB.
class FactLocalDataSource {
  FactLocalDataSource({this.assetPath = 'assets/data/facts_seed.json'});

  final String assetPath;
  List<FactEntity> _facts = const [];
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    // Decode + map on a background isolate so the ~188KB parse never blocks a
    // frame or the fact interstitial (PRD §6: never block the UI thread).
    _facts = await compute(_parseFacts, raw);
    _loaded = true;
  }

  /// All eligible facts at or below [complexityMax], excluding already-seen ids.
  Future<List<FactEntity>> eligibleFacts({
    required int complexityMax,
    required Set<String> excludeIds,
  }) async {
    await ensureLoaded();
    return _facts
        .where(
          (f) =>
              f.complexityRating <= complexityMax &&
              !excludeIds.contains(f.factId),
        )
        .toList(growable: false);
  }

  int get totalCount => _facts.length;
}
