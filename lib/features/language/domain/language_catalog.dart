import 'lexicon_entry.dart';

/// Display metadata for a selectable language.
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;
}

/// Known language display names plus helpers for deriving the set of target
/// languages actually present in the lexicon (so the picker never offers a
/// language with no vocabulary).
abstract class LanguageCatalog {
  static const Map<String, LanguageOption> known = {
    'ar': LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'de': LanguageOption(code: 'de', name: 'German', nativeName: 'Deutsch'),
    'en': LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    'es': LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'fr': LanguageOption(code: 'fr', name: 'French', nativeName: 'Français'),
    'it': LanguageOption(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    'ja': LanguageOption(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    'ru': LanguageOption(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    'zh': LanguageOption(code: 'zh', name: 'Mandarin', nativeName: '中文'),
  };

  /// Distinct, sorted target-language codes appearing in [entries].
  static List<String> distinctTargets(List<LexiconEntry> entries) {
    final set = <String>{for (final e in entries) e.targetLanguage};
    return set.toList()..sort();
  }

  static LanguageOption option(String code) =>
      known[code] ?? LanguageOption(code: code, name: code, nativeName: code);

  /// Languages written right-to-left (matches `writing_dir: rtl` in the lexicon).
  static const Set<String> rtlLanguages = {'ar', 'he', 'fa', 'ur'};

  static bool isRtl(String code) => rtlLanguages.contains(code);
}
