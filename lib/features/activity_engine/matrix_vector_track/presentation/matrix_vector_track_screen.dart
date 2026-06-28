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
import '../../../streak/cubit/streak_cubit.dart';
import '../bloc/vector_track_bloc.dart';
import '../domain/vector_track.dart';
import 'vector_track_painter.dart';

const double _gridSide = 270;

class MatrixVectorTrackScreen extends StatelessWidget {
  const MatrixVectorTrackScreen({
    super.key,
    this.targetLanguage = 'ja',
    this.repository,
  });

  final String targetLanguage;
  final LexiconRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo =
        repository ?? LexiconRepository(local: LexiconLocalDataSource());

    return BlocProvider<VectorTrackBloc>(
      create: (_) => VectorTrackBloc(lexicon: repo)
        ..add(VectorStarted(targetLanguage: targetLanguage)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('MATRIX VECTOR TRACK', style: TaaevonTypography.label),
        ),
        extendBodyBehindAppBar: true,
        body: Directionality(
          textDirection: LanguageCatalog.isRtl(targetLanguage)
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: GeometricBackground(
            seed: BackgroundSeedGenerator.fromUserId('vector-$targetLanguage'),
            child: SafeArea(
              child: BlocConsumer<VectorTrackBloc, VectorTrackState>(
                listener: (context, state) {
                  if (state is VectorComplete) {
                    context
                        .read<ProgressCubit>()
                        .recordCompletion(ActivityIds.vector);
                    context.read<StreakCubit>().recordActivity();
                  }
                },
                builder: (context, state) => switch (state) {
                  final VectorInProgress s => _ActiveView(state: s),
                  final VectorComplete s => _DoneView(moves: s.moves),
                  final VectorFailure s => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TaaevonDimensions.xl),
                        child: Text(s.message, style: TaaevonTypography.body),
                      ),
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
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.state});
  final VectorInProgress state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Steer the vector to row ${state.target.row + 1}, '
            'column ${state.targetColumnWord}',
            style: TaaevonTypography.body,
          ),
          const SizedBox(height: TaaevonDimensions.md),
          Center(
            child: SizedBox(
              width: _gridSide,
              height: _gridSide,
              child: CustomPaint(
                painter: VectorTrackPainter(
                  gridSize: state.gridSize,
                  current: state.current,
                  target: state.target,
                  columnWords: state.columnWords,
                ),
              ),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          Center(child: Text('Moves: ${state.moves}', style: TaaevonTypography.label)),
          const SizedBox(height: TaaevonDimensions.lg),
          _DirectionPad(
            onMove: (d) => context.read<VectorTrackBloc>().add(VectorMoved(d)),
          ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.moves});
  final int moves;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Target reached', style: TaaevonTypography.heading),
          const SizedBox(height: TaaevonDimensions.xs),
          Text('in $moves moves', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.lg),
          ElevatedButton(
            onPressed: () =>
                context.read<VectorTrackBloc>().add(const VectorRestarted()),
            child: const Text('New target'),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _DirectionPad extends StatelessWidget {
  const _DirectionPad({required this.onMove});
  final void Function(VectorDirection) onMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DirButton(direction: VectorDirection.up, onTap: () => onMove(VectorDirection.up)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DirButton(direction: VectorDirection.left, onTap: () => onMove(VectorDirection.left)),
            const SizedBox(width: 56),
            _DirButton(direction: VectorDirection.right, onTap: () => onMove(VectorDirection.right)),
          ],
        ),
        _DirButton(direction: VectorDirection.down, onTap: () => onMove(VectorDirection.down)),
      ],
    );
  }
}

class _DirButton extends StatelessWidget {
  const _DirButton({required this.direction, required this.onTap});
  final VectorDirection direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TaaevonDimensions.xs),
      child: Semantics(
        button: true,
        label: direction.name,
        child: Material(
          color: TaaevonColors.primaryAction,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
            child: SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(painter: _ArrowPainter(direction)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.direction);
  final VectorDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 12.0;
    final angle = switch (direction) {
      VectorDirection.up => -1.5707963,
      VectorDirection.down => 1.5707963,
      VectorDirection.left => 3.1415926,
      VectorDirection.right => 0.0,
    };
    final tip = c + Offset.fromDirection(angle, r);
    final back1 = c + Offset.fromDirection(angle + 2.4, r);
    final back2 = c + Offset.fromDirection(angle - 2.4, r);
    canvas.drawPath(
      Path()..addPolygon([tip, back1, back2], true),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.direction != direction;
}
