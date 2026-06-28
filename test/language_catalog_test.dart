import 'package:flutter_test/flutter_test.dart';
import 'package:taaevon/features/language/domain/language_catalog.dart';
import 'package:taaevon/features/language/domain/lexicon_entry.dart';

LexiconEntry _entry(String target) => LexiconEntry(
      wordId: 'w-$target-${target.hashCode}',
      sourceLanguage: 'en',
      targetLanguage: target,
      baseTerm: 'x',
      translatedTerm: 'y',
      lexicalCategory: 'everyday',
      syllableCount: 1,
      mathExtractedValue: 1,
    );

void main() {
  group('LanguageCatalog', () {
    test('distinctTargets returns sorted, unique target codes', () {
      final entries = [_entry('ja'), _entry('es'), _entry('ja'), _entry('es')];
      expect(LanguageCatalog.distinctTargets(entries), ['es', 'ja']);
    });

    test('distinctTargets on an empty lexicon is empty', () {
      expect(LanguageCatalog.distinctTargets(const []), isEmpty);
    });

    test('known options carry native names', () {
      expect(LanguageCatalog.option('ja').nativeName, '日本語');
      expect(LanguageCatalog.option('es').name, 'Spanish');
      expect(LanguageCatalog.option('en').nativeName, 'English');
    });

    test('an unknown code falls back to the code itself', () {
      final o = LanguageCatalog.option('zz');
      expect(o.name, 'zz');
      expect(o.nativeName, 'zz');
    });

    test('isRtl flags right-to-left languages', () {
      expect(LanguageCatalog.isRtl('ar'), isTrue);
      expect(LanguageCatalog.isRtl('fa'), isTrue);
      expect(LanguageCatalog.isRtl('en'), isFalse);
      expect(LanguageCatalog.isRtl('ja'), isFalse);
    });
  });
}
