import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../../core/widgets/numeric_answer_field.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../language/data/lexicon_local_datasource.dart';
import '../../language/data/lexicon_repository.dart';
import '../../sync_engine/dynamic_difficulty_calibrator.dart';
import '../bloc/math_bloc.dart';

const Map<InjectionMode, String> _modeLabels = {
  InjectionMode.fullInterlock: 'Full interlock',
  InjectionMode.mathInstructsLanguage: 'Math instructs language',
  InjectionMode.languageSeedsMath: 'Language seeds math',
  InjectionMode.parallelIndependent: 'Parallel',
};

class MathScreen extends StatelessWidget {
  const MathScreen({
    super.key,
    this.band = 3.0,
    this.cefr = CefrLevel.a1,
    this.targetLanguage = 'ja',
    this.repository,
  });

  final double band;
  final CefrLevel cefr;
  final String targetLanguage;
  final LexiconRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo =
        repository ?? LexiconRepository(local: LexiconLocalDataSource());

    return BlocProvider<MathBloc>(
      create: (_) => MathBloc(lexicon: repo)
        ..add(MathStarted(
          band: band,
          cefr: cefr,
          targetLanguage: targetLanguage,
        )),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('MATHEMATICS', style: TaaevonTypography.label),
        ),
        extendBodyBehindAppBar: true,
        body: GeometricBackground(
          seed: BackgroundSeedGenerator.fromUserId('math-$targetLanguage'),
          child: SafeArea(
            child: BlocBuilder<MathBloc, MathState>(
              builder: (context, state) => switch (state) {
                final MathInProgress s => _ProblemView(state: s),
                final MathFailure s => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(TaaevonDimensions.xl),
                      child: Text(s.message, style: TaaevonTypography.body),
                    ),
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TaaevonColors.mathAccent,
                    ),
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProblemView extends StatelessWidget {
  const _ProblemView({required this.state});
  final MathInProgress state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Band ${state.band.toStringAsFixed(2)}',
                  style: TaaevonTypography.label),
              _ModeBadge(mode: state.mode),
            ],
          ),
          const SizedBox(height: TaaevonDimensions.xl),
          // The (possibly injected) problem prompt.
          Container(
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            decoration: BoxDecoration(
              color: TaaevonColors.cardBackground,
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
              border: Border.all(color: TaaevonColors.cardBorder),
            ),
            child: Text(
              state.problem.prompt,
              style: TaaevonTypography.mono.copyWith(fontSize: 20, height: 1.5),
            ),
          ),
          if (state.problem.glossary.isNotEmpty) ...[
            const SizedBox(height: TaaevonDimensions.md),
            Text('New vocabulary', style: TaaevonTypography.label),
            const SizedBox(height: TaaevonDimensions.sm),
            Wrap(
              spacing: TaaevonDimensions.sm,
              runSpacing: TaaevonDimensions.sm,
              children: [
                for (final item in state.problem.glossary)
                  _GlossaryChip(text: item.gloss),
              ],
            ),
          ],
          const SizedBox(height: TaaevonDimensions.lg),
          _Feedback(outcome: state.lastOutcome),
          const Spacer(),
          NumericAnswerField(
            hintText: 'Your answer',
            submitLabel: 'Submit',
            onSubmit: (value) =>
                context.read<MathBloc>().add(MathAnswerSubmitted(value)),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          TextButton(
            onPressed: () =>
                context.read<MathBloc>().add(const MathNextRequested()),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.mode});
  final InjectionMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: TaaevonColors.mathAccent,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusPill),
      ),
      child: Text(
        (_modeLabels[mode] ?? '').toUpperCase(),
        style: const TextStyle(
          fontFamily: TaaevonTypography.fontFamilyBody,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _GlossaryChip extends StatelessWidget {
  const _GlossaryChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TaaevonDimensions.md,
        vertical: TaaevonDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: TaaevonColors.backgroundDeep,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusSm),
        border: Border.all(color: TaaevonColors.languageAccent, width: 1),
      ),
      child: Text(text, style: TaaevonTypography.body.copyWith(fontSize: 16)),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.outcome});
  final AnswerOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (outcome) {
      AnswerOutcome.correct => ('Correct — difficulty rising', TaaevonColors.success),
      AnswerOutcome.incorrect => ('Not quite — recalibrating', TaaevonColors.warning),
      AnswerOutcome.none => ('', Colors.transparent),
    };
    if (text.isEmpty) return const SizedBox(height: 20);
    // liveRegion so a screen reader announces the correct/incorrect outcome —
    // the core feedback of the activity — without a focus change (WCAG 4.1.3).
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: TaaevonTypography.label.copyWith(color: color, fontSize: 14),
      ),
    );
  }
}
