/// A parameterised math problem. [promptTemplate] uses `{name}` placeholders
/// bound at runtime; [computeAnswer] returns the expected integer answer for a
/// given set of bindings. [tier] is the curriculum tier (1 Foundational,
/// 2 Intermediate, 3 Advanced).
class MathProblemTemplate {
  MathProblemTemplate({
    required this.id,
    required this.domain,
    required this.tier,
    required this.promptTemplate,
    required this.variableNames,
    required this.computeAnswer,
  });

  final String id;
  final String domain;
  final int tier;
  final String promptTemplate;
  final List<String> variableNames;
  final int Function(Map<String, int> bindings) computeAnswer;
}
