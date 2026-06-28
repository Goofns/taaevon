import 'package:equatable/equatable.dart';

/// One selectable translation tile in a Polygon Polyglot round.
class PolyglotOption extends Equatable {
  const PolyglotOption({
    required this.text,
    required this.isCorrect,
    this.romanization,
  });

  final String text; // target-language form (e.g. ありがとう)
  final String? romanization; // e.g. "arigatou"
  final bool isCorrect;

  @override
  List<Object?> get props => [text, isCorrect];
}

/// A single vertex challenge: translate [promptTerm] by picking the right tile.
class PolyglotRound extends Equatable {
  const PolyglotRound({
    required this.promptTerm,
    required this.targetLanguage,
    required this.options,
    required this.correctText,
  });

  final String promptTerm; // source-language word, e.g. "thank you"
  final String targetLanguage;
  final List<PolyglotOption> options;
  final String correctText;

  int get correctIndex => options.indexWhere((o) => o.isCorrect);

  @override
  List<Object?> get props => [promptTerm, options];
}
