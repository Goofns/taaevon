import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/activity_engine/isometric_tessellation/presentation/isometric_tessellation_screen.dart';
import 'package:taaevon/features/activity_engine/matrix_vector_track/presentation/matrix_vector_track_screen.dart';
import 'package:taaevon/features/activity_engine/polygon_polyglot/presentation/polygon_polyglot_screen.dart';
import 'package:taaevon/features/language/data/lexicon_repository.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';
import 'package:taaevon/features/math/presentation/math_screen.dart';

/// Render-smoke tests for the four gameplay screens. They pump each screen with
/// a stub lexicon (no real rootBundle I/O) on a generous surface, then assert the
/// screen builds — through its bloc to its CustomPainters — without throwing.
///
/// These exercise the real paint() paths (IncompletePolygonPainter,
/// VectorTrackPainter, TessellationPainter, GeometricBackground), which the
/// bloc-unit tests never touch. Explicit pumps (not pumpAndSettle) avoid hanging
/// on any transient loading spinner.
class _StubLexiconRepo implements LexiconRepository {
  _StubLexiconRepo(this._entries);
  final List<LexiconEntry> _entries;

  @override
  Future<List<LexiconEntry>> all() async => _entries;

  @override
  Future<List<LexiconEntry>> entriesForTarget(String targetLanguage) async =>
      _entries.where((e) => e.targetLanguage == targetLanguage).toList();
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

// Numerals 1..10 in one target language: enough for Polyglot's option pool,
// Vector's column number-words, and Math's operand injection.
final _stub = _StubLexiconRepo([for (var n = 1; n <= 10; n++) _num(n)]);

Future<void> _pumpSettleFrames(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUp(() {
    // A tall surface so dense activity layouts don't trip RenderFlex overflow
    // (which would throw and fail the no-exception assertion spuriously).
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Polygon Polyglot renders through its painter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: PolygonPolyglotScreen(targetLanguage: 'es', repository: _stub),
      ),
    );
    await _pumpSettleFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(PolygonPolyglotScreen), findsOneWidget);
  });

  testWidgets('Matrix Vector Track renders through its painter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MatrixVectorTrackScreen(targetLanguage: 'es', repository: _stub),
      ),
    );
    await _pumpSettleFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(MatrixVectorTrackScreen), findsOneWidget);
  });

  testWidgets('Math screen renders through its bloc', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MathScreen(targetLanguage: 'es', repository: _stub),
      ),
    );
    await _pumpSettleFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(MathScreen), findsOneWidget);
  });

  testWidgets('Isometric Tessellation renders through its painter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: IsometricTessellationScreen()),
    );
    await _pumpSettleFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(IsometricTessellationScreen), findsOneWidget);
  });
}
