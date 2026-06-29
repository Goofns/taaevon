import '../language/domain/lexicon_entry.dart';
import 'dynamic_difficulty_calibrator.dart';

/// A vocabulary item surfaced to the learner while solving a math problem.
class GlossaryItem {
  const GlossaryItem({
    required this.script,
    required this.value,
    this.romanization,
  });

  final String script; // target-language form, e.g. さん
  final int value; // numeric meaning, e.g. 3
  final String? romanization; // e.g. "san"

  String get gloss => romanization == null
      ? '$script = $value'
      : '$script ($romanization) = $value';
}

/// A math problem after cross-domain injection.
class InjectedProblem {
  const InjectedProblem({
    required this.prompt,
    required this.bindings,
    required this.glossary,
    required this.mode,
  });

  final String prompt;
  final Map<String, int> bindings;
  final List<GlossaryItem> glossary;
  final InjectionMode mode;
}

/// Interlocking Progression engine (PRD §10.1, §10.3).
///
/// Two directions:
///  * [inject] — render numeric placeholders in a math template as
///    target-language number-words (e.g. x₀ = さん), surfacing vocabulary while
///    the learner works at their true math level.
///  * [seedBindingsFromVocab] — derive math variable values from language data
///    (syllable counts) so a completed language module feeds the math module.
class InterlockingProgression {
  const InterlockingProgression();

  /// value -> numeral entry, restricted to a single target language's numerals.
  static Map<int, LexiconEntry> _numeralsByValue(List<LexiconEntry> vocab) {
    final map = <int, LexiconEntry>{};
    for (final w in vocab.where((w) => w.isNumeral)) {
      map.putIfAbsent(w.mathExtractedValue, () => w);
    }
    return map;
  }

  /// Replace `{name}` placeholders in [template] with the values in [bindings].
  /// When [mode] interlocks language INTO math, numeric values that have a
  /// matching numeral in [targetVocab] are rendered in the target script and
  /// added to the returned glossary.
  InjectedProblem inject({
    required String template,
    required Map<String, int> bindings,
    required List<LexiconEntry> targetVocab,
    required InjectionMode mode,
  }) {
    final useLanguage = mode == InjectionMode.fullInterlock ||
        mode == InjectionMode.mathInstructsLanguage;
    final numerals = _numeralsByValue(targetVocab);

    var prompt = template;
    final glossary = <GlossaryItem>[];
    final seenValues = <int>{};

    bindings.forEach((name, value) {
      var replacement = value.toString();
      if (useLanguage && numerals.containsKey(value)) {
        final w = numerals[value]!;
        replacement = w.translatedTerm;
        if (seenValues.add(value)) {
          glossary.add(
            GlossaryItem(
              script: w.translatedTerm,
              value: value,
              romanization: w.romanization,
            ),
          );
        }
      }
      prompt = prompt.replaceAll('{$name}', replacement);
    });

    return InjectedProblem(
      prompt: prompt,
      bindings: bindings,
      glossary: glossary,
      mode: mode,
    );
  }

  /// LANGUAGE_SEEDS_MATH: map each placeholder [name] to a numeric value drawn
  /// from the corresponding vocabulary item's syllable count.
  Map<String, int> seedBindingsFromVocab(
    List<String> names,
    List<LexiconEntry> vocab,
  ) {
    assert(vocab.isNotEmpty, 'vocab must not be empty');
    return {
      for (var i = 0; i < names.length; i++)
        names[i]: vocab[i % vocab.length].syllableCount,
    };
  }
}
