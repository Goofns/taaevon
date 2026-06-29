import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/isometric_tessellation/presentation/isometric_tessellation_screen.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/presentation/matrix_vector_track_screen.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/presentation/polygon_polyglot_screen.dart';
import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/language/presentation/language_selection_screen.dart';
import 'package:taaevon/features/math/presentation/math_screen.dart';

/// Verifies the geometric layouts don't clip (RenderFlex overflow throws in a
/// test) at the 1.5x text scale the app clamps to. This is the headless stand-in
/// for on-device large-text checks: a fixed-height tile that can't fit scaled
/// text fails here instead of silently clipping on a phone (WCAG 1.4.4).
class _StubLexiconRepo implements LexiconRepository {
  _StubLexiconRepo(this._entries);
  final List<LexiconEntry> _entries;
  @override
  Future<List<LexiconEntry>> all() async => _entries;
  @override
  Future<List<LexiconEntry>> entriesForTarget(String t) async =>
      _entries.where((e) => e.targetLanguage == t).toList();
}

LexiconEntry _num(int n) => LexiconEntry(
      wordId: 'es-num-$n',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      baseTerm: '$n',
      translatedTerm: 'palabra$n',
      lexicalCategory: 'number',
      syllableCount: 2,
      mathExtractedValue: n,
    );

final _stub = _StubLexiconRepo([for (var n = 1; n <= 10; n++) _num(n)]);

Widget _scaled(Widget screen) => MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: screen,
        ),
      ),
    );

Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  Future<void> noOverflow(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_scaled(screen));
    await _frames(tester);
    expect(tester.takeException(), isNull);
  }

  testWidgets('Polygon Polyglot no overflow at 1.5x', (tester) async {
    await noOverflow(
      tester,
      PolygonPolyglotScreen(targetLanguage: 'es', repository: _stub),
    );
  });

  testWidgets('Matrix Vector Track no overflow at 1.5x', (tester) async {
    await noOverflow(
      tester,
      MatrixVectorTrackScreen(targetLanguage: 'es', repository: _stub),
    );
  });

  testWidgets('Math screen no overflow at 1.5x', (tester) async {
    await noOverflow(
      tester,
      MathScreen(targetLanguage: 'es', repository: _stub),
    );
  });

  testWidgets('Isometric Tessellation no overflow at 1.5x', (tester) async {
    await noOverflow(tester, const IsometricTessellationScreen());
  });

  testWidgets('Language selection no overflow at 1.5x', (tester) async {
    await noOverflow(tester, LanguageSelectionScreen(repository: _stub));
  });
}
