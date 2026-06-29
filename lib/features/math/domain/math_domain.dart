/// A selectable mathematics domain in the category matrix (PRD §7.2).
class MathDomain {
  const MathDomain({
    required this.id,
    required this.name,
    required this.tier,
    required this.band,
    required this.glyphSides,
    required this.unlocked,
    required this.completion,
  });

  final String id;
  final String name;
  final int tier; // 1 Foundational, 2 Intermediate, 3 Advanced
  final double band; // representative DDC band (1.0–3.99)
  final int glyphSides; // polygon glyph vertices
  final bool unlocked;
  final double completion; // 0.0–1.0
}

/// Static catalog of math domains spanning Pre-K foundations to post-graduate.
abstract class MathDomainCatalog {
  static const List<MathDomain> domains = [
    // Tier 1 — Foundational
    MathDomain(
        id: 'numeracy',
        name: 'Numeracy',
        tier: 1,
        band: 1.0,
        glyphSides: 3,
        unlocked: true,
        completion: 0.8),
    MathDomain(
        id: 'arithmetic',
        name: 'Arithmetic',
        tier: 1,
        band: 1.5,
        glyphSides: 3,
        unlocked: true,
        completion: 0.6),
    MathDomain(
        id: 'fractions',
        name: 'Fractions',
        tier: 1,
        band: 1.8,
        glyphSides: 4,
        unlocked: true,
        completion: 0.2),
    // Tier 2 — Intermediate
    MathDomain(
        id: 'algebra',
        name: 'Algebra',
        tier: 2,
        band: 2.2,
        glyphSides: 4,
        unlocked: true,
        completion: 0.3),
    MathDomain(
        id: 'geometry',
        name: 'Geometry',
        tier: 2,
        band: 2.5,
        glyphSides: 5,
        unlocked: true,
        completion: 0.0),
    MathDomain(
        id: 'trigonometry',
        name: 'Trigonometry',
        tier: 2,
        band: 2.8,
        glyphSides: 5,
        unlocked: false,
        completion: 0.0),
    // Tier 3 — Advanced
    MathDomain(
        id: 'calculus',
        name: 'Calculus',
        tier: 3,
        band: 3.0,
        glyphSides: 6,
        unlocked: true,
        completion: 0.0),
    MathDomain(
        id: 'linear-algebra',
        name: 'Linear Algebra',
        tier: 3,
        band: 3.4,
        glyphSides: 6,
        unlocked: false,
        completion: 0.0),
    MathDomain(
        id: 'abstract',
        name: 'Abstract Algebra',
        tier: 3,
        band: 3.7,
        glyphSides: 7,
        unlocked: false,
        completion: 0.0),
  ];

  static List<MathDomain> forTier(int tier) =>
      domains.where((d) => d.tier == tier).toList(growable: false);

  static const Map<int, String> tierLabels = {
    1: 'Foundational',
    2: 'Intermediate',
    3: 'Advanced',
  };
}
