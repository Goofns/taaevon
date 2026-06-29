import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../bloc/fact_bloc.dart';
import '../domain/fact_entity.dart';

/// Non-blocking overlay card shown during loads/transitions. Renders nothing
/// until the [FactBloc] has a fact ready, then fades in over 120 ms.
class FactInterstitial extends StatelessWidget {
  const FactInterstitial({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FactBloc, FactState>(
      builder: (context, state) {
        final card = switch (state) {
          FactReady(:final fact) => _FactCard(fact: fact),
          FactDepleted() => const _MessageCard(
              'You have seen every fact in this session.',
            ),
          FactFailure(:final message) =>
            _MessageCard('Could not load a fact.\n$message'),
          _ => const SizedBox.shrink(),
        };
        return AnimatedSwitcher(
          // Asymmetric: ease in over 120ms, fade out faster at 80ms so a new
          // fact replaces the old one crisply (PRD §6.3).
          duration: const Duration(milliseconds: 120),
          reverseDuration: const Duration(milliseconds: 80),
          child: card,
        );
      },
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact});
  final FactEntity fact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // liveRegion so the fact is announced when it fades in (it appears in
      // place with no focus change), incl. the 'Show a fact' path (WCAG 4.1.3).
      liveRegion: true,
      label: 'Did you know: ${fact.content}. Category ${fact.category}, '
          'complexity ${fact.complexityRating} of 5.',
      child: Container(
        key: ValueKey(fact.factId),
        margin: const EdgeInsets.all(TaaevonDimensions.md),
        padding: const EdgeInsets.all(TaaevonDimensions.lg),
        decoration: BoxDecoration(
          color: TaaevonColors.factBackground,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: TaaevonColors.primaryAction.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryBadge(label: fact.category),
            const SizedBox(height: TaaevonDimensions.md),
            Text(fact.content, style: TaaevonTypography.factCard),
            const SizedBox(height: TaaevonDimensions.md),
            _ComplexityDots(rating: fact.complexityRating),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: TaaevonColors.factBadge,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusPill),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: TaaevonTypography.fontFamilyBody,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ComplexityDots extends StatelessWidget {
  const _ComplexityDots({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: i < rating ? TaaevonColors.factBadge : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        margin: const EdgeInsets.all(TaaevonDimensions.md),
        padding: const EdgeInsets.all(TaaevonDimensions.lg),
        decoration: BoxDecoration(
          color: TaaevonColors.factBackground,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusXl),
        ),
        child: Text(message, style: TaaevonTypography.factCard),
      ),
    );
  }
}
