import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/presentation/language_selection_screen.dart';

/// Pumps the language picker with its REAL repository, which loads
/// lexicon_seed.json from the asset bundle via rootBundle — the exact path that
/// crashed on a device when the asset wasn't declared in pubspec. If the asset
/// is undeclared, missing, or malformed, the FutureBuilder resolves to an error
/// and this test fails (takeException or a failed find), catching the regression
/// in CI rather than on a phone.
void main() {
  testWidgets('loads the real lexicon asset and renders the picker',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LanguageSelectionScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // This header only renders after the lexicon future resolves with data, so
    // finding it proves the asset loaded and parsed (no error branch).
    expect(find.text('Tap a language to play or review.'), findsOneWidget);
  });
}
