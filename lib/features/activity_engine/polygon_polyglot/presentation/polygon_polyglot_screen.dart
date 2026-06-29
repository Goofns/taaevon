import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/typography.dart';
import '../../../background/background_seed_generator.dart';
import '../../../background/geometric_background_painter.dart';
import '../../../language/data/lexicon_local_datasource.dart';
import '../../../language/data/lexicon_repository.dart';
import '../../../language/domain/language_catalog.dart';
import '../../../progress/cubit/progress_cubit.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../streak/cubit/streak_cubit.dart';
import '../../../sync_engine/dynamic_difficulty_calibrator.dart';
import '../bloc/polyglot_bloc.dart';
import 'incomplete_polygon_painter.dart';
import 'option_tile.dart';

const Map<String, String> _languageNames = {
  'ja': 'Japanese',
  'es': 'Spanish',
  'en': 'English',
};

class PolygonPolyglotScreen extends StatelessWidget {
  const PolygonPolyglotScreen({
    super.key,
    this.targetLanguage = 'ja',
    this.cefr = CefrLevel.a1,
    this.repository,
  });

  final String targetLanguage;
  final CefrLevel cefr;
  final LexiconRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo =
        repository ?? LexiconRepository(local: LexiconLocalDataSource());

    return BlocProvider<PolyglotBloc>(
      create: (_) => PolyglotBloc(repository: repo)
        ..add(PolyglotStarted(targetLanguage: targetLanguage, cefr: cefr)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('POLYGON POLYGLOT', style: TaaevonTypography.label),
        ),
        extendBodyBehindAppBar: true,
        body: Directionality(
          textDirection: LanguageCatalog.isRtl(targetLanguage)
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: GeometricBackground(
            seed: BackgroundSeedGenerator.fromUserId('polyglot-$targetLanguage'),
            child: SafeArea(
              child: BlocConsumer<PolyglotBloc, PolyglotState>(
                listener: (context, state) {
                  if (state is PolyglotComplete) {
                    context
                        .read<ProgressCubit>()
                        .recordCompletion(ActivityIds.polyglot);
                    context.read<StreakCubit>().recordActivity();
                  }
                },
                builder: (context, state) => switch (state) {
                  final PolyglotInProgress s =>
                    _ActiveView(state: s, language: targetLanguage),
                  final PolyglotComplete s =>
                    _CompleteView(total: s.totalVertices),
                  final PolyglotFailure s => _MessageView(text: s.message),
                  _ => const Center(child: _GeometricLoader()),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.state, required this.language});

  final PolyglotInProgress state;
  final String language;

  @override
  Widget build(BuildContext context) {
    final langName = _languageNames[language] ?? language;
    return Padding(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Translate to $langName', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.xs),
          Text(state.round.promptTerm, style: TaaevonTypography.display.copyWith(fontSize: 28, letterSpacing: 0)),
          const SizedBox(height: TaaevonDimensions.md),
          SizedBox(
            height: 200,
            child: _Shake(
              shakeKey: ValueKey(state.wrongAttempts),
              enabled: state.wrongAttempts > 0 &&
                  !context.watch<SettingsCubit>().state.reduceMotion,
              child: CustomPaint(
                painter: IncompletePolygonPainter(
                  placedVertices: state.placedVertices,
                  totalVertices: state.totalVertices,
                  complete: false,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          Center(
            // liveRegion so the right/wrong outcome and progress are announced
            // after each answer — otherwise the result is conveyed only by the
            // shake/polygon repaint, silent to screen readers (WCAG 4.1.3).
            child: Semantics(
              liveRegion: true,
              label: state.lastAnswerWrong
                  ? 'Incorrect, try again. ${state.placedVertices} of '
                      '${state.totalVertices} vertices placed.'
                  : '${state.placedVertices} of ${state.totalVertices} '
                      'vertices placed.',
              child: ExcludeSemantics(
                child: Text(
                  '${state.placedVertices} / ${state.totalVertices} vertices',
                  style: TaaevonTypography.label,
                ),
              ),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.md),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: TaaevonDimensions.sm,
                crossAxisSpacing: TaaevonDimensions.sm,
                childAspectRatio: 2.4,
              ),
              itemCount: state.round.options.length,
              itemBuilder: (context, i) => OptionTile(
                option: state.round.options[i],
                onTap: () => context
                    .read<PolyglotBloc>()
                    .add(PolyglotAnswerSelected(i)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaaevonDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: IncompletePolygonPainter(
                  placedVertices: total,
                  totalVertices: total,
                  complete: true,
                ),
              ),
            ),
            const SizedBox(height: TaaevonDimensions.lg),
            Text('Polygon solved', style: TaaevonTypography.heading),
            const SizedBox(height: TaaevonDimensions.xs),
            Text('$total vertices locked', style: TaaevonTypography.label),
            const SizedBox(height: TaaevonDimensions.lg),
            ElevatedButton(
              onPressed: () =>
                  context.read<PolyglotBloc>().add(const PolyglotRestarted()),
              child: const Text('Play again'),
            ),
            const SizedBox(height: TaaevonDimensions.sm),
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

class _MessageView extends StatelessWidget {
  const _MessageView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(TaaevonDimensions.xl),
          child: Text(text, textAlign: TextAlign.center, style: TaaevonTypography.body),
        ),
      );
}

class _GeometricLoader extends StatelessWidget {
  const _GeometricLoader();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2, color: TaaevonColors.languageAccent),
      );
}

/// Damped horizontal shake that re-runs whenever [shakeKey] changes.
class _Shake extends StatelessWidget {
  const _Shake({
    required this.shakeKey,
    required this.enabled,
    required this.child,
  });

  final Key shakeKey;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return TweenAnimationBuilder<double>(
      key: shakeKey,
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      builder: (context, t, inner) {
        final dx = math.sin(t * math.pi * 4) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: inner);
      },
      child: child,
    );
  }
}
