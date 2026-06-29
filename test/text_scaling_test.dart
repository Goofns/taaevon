import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/presentation/matrix_vector_track_screen.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/presentation/polygon_polyglot_screen.dart';
import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';

/// Verifies the layouts that have been hardened for large text don't clip
/// (RenderFlex overflow throws in a test) at the 1.5x scale the app clamps to —
/// the headless stand-in for an on-device large-text pass (WCAG 1.4.4).
///
/// Scope: Polygon Polyglot (option grid sized to fit at 1.5x) and Matrix Vector
/// Track. The Math, Tessellation, and Language screens still have fixed-height /
/// non-scrolling sections that overflow under large text; fixing those needs
/// intrinsic-height layout work best validated on a device and is tracked as a
/// follow-up. The global 1.5x clamp in main.dart bounds the damage meanwhile.
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
}
