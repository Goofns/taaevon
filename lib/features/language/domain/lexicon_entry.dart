import 'package:equatable/equatable.dart';

/// A single translated lexicon entry from the universal lexicon.
class LexiconEntry extends Equatable {
  const LexiconEntry({
    required this.wordId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.baseTerm,
    required this.translatedTerm,
    required this.lexicalCategory,
    required this.syllableCount,
    required this.mathExtractedValue,
    this.partOfSpeech,
    this.romanization,
    this.phoneticIpa,
    this.cefrLevel,
  });

  final String wordId;
  final String sourceLanguage;
  final String targetLanguage;
  final String baseTerm;
  final String translatedTerm;
  final String lexicalCategory;
  final int syllableCount;

  /// Numeric value the DDC injector can bind to a math variable. For numerals
  /// this is the actual number (san -> 3); otherwise it defaults to the
  /// syllable count.
  final int mathExtractedValue;

  final String? partOfSpeech;
  final String? romanization;
  final String? phoneticIpa;
  final String? cefrLevel;

  bool get isNumeral => partOfSpeech == 'numeral';

  factory LexiconEntry.fromJson(Map<String, dynamic> json, String fallbackId) {
    final syllables = (json['syllable_count'] as num?)?.toInt() ?? 1;
    return LexiconEntry(
      wordId: (json['word_id'] as String?) ?? fallbackId,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      baseTerm: json['base_term'] as String,
      translatedTerm: json['translated_term'] as String,
      lexicalCategory: json['lexical_category'] as String,
      syllableCount: syllables,
      mathExtractedValue:
          (json['math_extracted_value'] as num?)?.toInt() ?? syllables,
      partOfSpeech: json['part_of_speech'] as String?,
      romanization: json['romanization'] as String?,
      phoneticIpa: json['phonetic_ipa'] as String?,
      cefrLevel: json['cefr_level'] as String?,
    );
  }

  @override
  List<Object?> get props => [wordId];
}
