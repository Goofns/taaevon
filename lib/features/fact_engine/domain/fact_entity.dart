import 'package:equatable/equatable.dart';

/// A single micro-learning fact served during loading/transition states.
class FactEntity extends Equatable {
  const FactEntity({
    required this.factId,
    required this.category,
    required this.content,
    required this.complexityRating,
    required this.verificationSource,
    this.subcategory,
  });

  final String factId;
  final String category;
  final String? subcategory;
  final String content;
  final int complexityRating; // 1–5
  final String verificationSource;

  /// Builds an entity from a seed-JSON map. The seed file does not carry UUIDs,
  /// so a stable [fallbackId] (e.g. the array index) is supplied by the caller.
  factory FactEntity.fromJson(Map<String, dynamic> json, String fallbackId) {
    return FactEntity(
      factId: (json['fact_id'] as String?) ?? fallbackId,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      content: json['content'] as String,
      complexityRating: json['complexity_rating'] as int,
      verificationSource: json['verification_source'] as String,
    );
  }

  @override
  List<Object?> get props => [factId];
}
