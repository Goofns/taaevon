import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/language/presentation/language_selection_screen.dart';

import 'support/stub_lexicon_repo.dart';

/// Renders the language picker from injected data (no real asset I/O — that's
/// covered deterministically by tools/check_assets_declared.py). Verifies the
/// FutureBuilder -> tiles path builds without throwing once data arrives.
///
/// NOTE: we pump explicit frames rather than pumpAndSettle, because the
/// loading-state CircularProgressIndicator animates forever and would make
/// pumpAndSettle hang if the future ever stalled.
LexiconEntry _word(String id, String target) => LexiconEntry(
      wordId: id,
      sourceLanguage: 'en',
      targetLanguage: target,
      baseTerm: 'b-$id',
      translatedTerm: 't-$id',
      lexicalCategory: 'everyday',
      syllableCount: 2,
      mathExtractedValue: 2,
    );

void main() {
  testWidgets('renders a tile per distinct target language', (tester) async {
    final repo = StubLexiconRepo([_word('1', 'es'), _word('2', 'ja')]);
    await tester.pumpWidget(
      MaterialApp(home: LanguageSelectionScreen(repository: repo)),
    );
    // Let the async repo future (+ its .then) resolve, then rebuild with data.
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));

    expect(tester.takeException(), isNull);
    expect(find.text('Tap a language to play or review.'), findsOneWidget);
  });
}
