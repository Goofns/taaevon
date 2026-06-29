import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../language/data/lexicon_repository.dart';
import '../bloc/review_cubit.dart';
import '../data/review_store.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.targetLanguage,
    this.repository,
  });

  final String targetLanguage;
  final LexiconRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo =
        repository ?? LexiconRepository.production();
    return BlocProvider<ReviewCubit>(
      create: (_) => ReviewCubit(
        lexicon: repo,
        store: SharedPrefsReviewStore(),
      )..start(targetLanguage),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('VOCABULARY REVIEW', style: TaaevonTypography.label),
        ),
        extendBodyBehindAppBar: true,
        body: GeometricBackground(
          seed: BackgroundSeedGenerator.fromUserId('review-$targetLanguage'),
          child: SafeArea(
            child: BlocBuilder<ReviewCubit, ReviewState>(
              builder: (context, state) => switch (state) {
                final ReviewInProgress s => _SessionView(state: s),
                final ReviewComplete s => _DoneView(reviewed: s.reviewed),
                ReviewEmpty() => const _MessageView(
                    'Nothing is due for review right now.\n'
                    'Come back later to keep your words fresh.',
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TaaevonColors.languageAccent,
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

class _SessionView extends StatelessWidget {
  const _SessionView({required this.state});
  final ReviewInProgress state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReviewCubit>();
    final w = state.current;
    return Padding(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${state.done + 1} / ${state.total}',
              style: TaaevonTypography.label),
          const Spacer(),
          Center(
            child: Text(
              w.baseTerm,
              textAlign: TextAlign.center,
              style:
                  TaaevonTypography.display.copyWith(fontSize: 30, letterSpacing: 0),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.lg),
          if (state.revealed) ...[
            Center(
              child: Text(
                w.translatedTerm,
                textAlign: TextAlign.center,
                style: TaaevonTypography.heading
                    .copyWith(fontSize: 26, color: TaaevonColors.languageAccent),
              ),
            ),
            if (w.romanization != null) ...[
              const SizedBox(height: 4),
              Center(child: Text(w.romanization!, style: TaaevonTypography.label)),
            ],
          ] else
            const Center(child: Text('• • •', style: TaaevonTypography.heading)),
          const Spacer(),
          if (!state.revealed)
            ElevatedButton(onPressed: cubit.reveal, child: const Text('Reveal'))
          else
            Row(
              children: [
                Expanded(
                  child: _GradeButton(
                    label: 'Again',
                    color: TaaevonColors.error,
                    onTap: () => cubit.grade(1),
                  ),
                ),
                const SizedBox(width: TaaevonDimensions.sm),
                Expanded(
                  child: _GradeButton(
                    label: 'Hard',
                    color: TaaevonColors.warning,
                    onTap: () => cubit.grade(3),
                  ),
                ),
                const SizedBox(width: TaaevonDimensions.sm),
                Expanded(
                  child: _GradeButton(
                    label: 'Good',
                    color: TaaevonColors.secondaryAction,
                    onTap: () => cubit.grade(4),
                  ),
                ),
                const SizedBox(width: TaaevonDimensions.sm),
                Expanded(
                  child: _GradeButton(
                    label: 'Easy',
                    color: TaaevonColors.success,
                    onTap: () => cubit.grade(5),
                  ),
                ),
              ],
            ),
          const SizedBox(height: TaaevonDimensions.sm),
        ],
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.reviewed});
  final int reviewed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Review complete', style: TaaevonTypography.heading),
          const SizedBox(height: TaaevonDimensions.xs),
          Text('$reviewed words reviewed', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.lg),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaaevonDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: TaaevonTypography.body),
            const SizedBox(height: TaaevonDimensions.lg),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
