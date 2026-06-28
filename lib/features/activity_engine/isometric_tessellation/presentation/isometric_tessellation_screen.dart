import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/typography.dart';
import '../../../background/background_seed_generator.dart';
import '../../../background/geometric_background_painter.dart';
import '../../../progress/cubit/progress_cubit.dart';
import '../../../streak/cubit/streak_cubit.dart';
import '../bloc/tessellation_bloc.dart';
import '../domain/tessellation_board.dart';
import 'tessellation_painter.dart';

const double _gridSide = 270;

class IsometricTessellationScreen extends StatelessWidget {
  const IsometricTessellationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TessellationBloc>(
      create: (_) => TessellationBloc()..add(const TessellationStarted()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('ISOMETRIC TESSELLATION', style: TaaevonTypography.label),
        ),
        extendBodyBehindAppBar: true,
        body: GeometricBackground(
          seed: BackgroundSeedGenerator.fromUserId('tessellation'),
          child: SafeArea(
            child: BlocConsumer<TessellationBloc, TessellationState>(
              listener: (context, state) {
                if (state is TessellationComplete) {
                  context
                      .read<ProgressCubit>()
                      .recordCompletion(ActivityIds.tessellation);
                  context.read<StreakCubit>().recordActivity();
                }
              },
              builder: (context, state) => switch (state) {
                final TessellationInProgress s => _ActiveView(state: s),
                final TessellationComplete s => _DoneView(total: s.total),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.state});
  final TessellationInProgress state;

  void _handleTap(BuildContext context, Offset local) {
    final cellSize = _gridSide /
        (state.rows > state.cols ? state.rows : state.cols);
    final row = (local.dy / cellSize).floor();
    final col = (local.dx / cellSize).floor();
    if (row < 0 || row >= state.rows || col < 0 || col >= state.cols) return;
    context.read<TessellationBloc>().add(TessellationCellTapped(Cell(row, col)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiles earned: ${state.credits}', style: TaaevonTypography.label),
              Text('${state.placed} / ${state.total} placed', style: TaaevonTypography.label),
            ],
          ),
          const SizedBox(height: TaaevonDimensions.md),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _handleTap(context, d.localPosition),
              child: SizedBox(
                width: _gridSide,
                height: _gridSide,
                child: CustomPaint(
                  painter: TessellationPainter(
                    filled: state.filled,
                    rows: state.rows,
                    cols: state.cols,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.sm),
          Center(
            child: Text(
              state.credits > 0
                  ? 'Tap an empty cell next to your pattern to place a tile.'
                  : 'Solve the problem to earn a tile.',
              style: TaaevonTypography.label,
            ),
          ),
          const SizedBox(height: TaaevonDimensions.lg),
          _ProblemCard(prompt: state.prompt, outcome: state.lastOutcome),
          const SizedBox(height: TaaevonDimensions.md),
          _IntInput(
            onSubmit: (v) =>
                context.read<TessellationBloc>().add(TessellationAnswerSubmitted(v)),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.prompt, required this.outcome});
  final String prompt;
  final TileOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (note, color) = switch (outcome) {
      TileOutcome.earned => ('Tile earned!', TaaevonColors.success),
      TileOutcome.missed => ('No tile — try the next one', TaaevonColors.warning),
      TileOutcome.none => ('', Colors.transparent),
    };
    return Container(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      decoration: BoxDecoration(
        color: TaaevonColors.cardBackground,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
        border: Border.all(color: TaaevonColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt, style: TaaevonTypography.mono.copyWith(fontSize: 22)),
          if (note.isNotEmpty) ...[
            const SizedBox(height: TaaevonDimensions.sm),
            Text(note, style: TaaevonTypography.label.copyWith(color: color)),
          ],
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final side = math.sqrt(total).round(); // square panel
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _gridSide,
            height: _gridSide,
            child: CustomPaint(
              painter: TessellationPainter(
                filled: {
                  for (var r = 0; r < side; r++)
                    for (var c = 0; c < side; c++) Cell(r, c),
                },
                rows: side,
                cols: side,
              ),
            ),
          ),
          const SizedBox(height: TaaevonDimensions.lg),
          Text('Tessellation complete', style: TaaevonTypography.heading),
          const SizedBox(height: TaaevonDimensions.xs),
          Text('$total tiles placed', style: TaaevonTypography.label),
          const SizedBox(height: TaaevonDimensions.lg),
          ElevatedButton(
            onPressed: () =>
                context.read<TessellationBloc>().add(const TessellationStarted()),
            child: const Text('Play again'),
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

class _IntInput extends StatefulWidget {
  const _IntInput({required this.onSubmit});
  final void Function(int value) onSubmit;

  @override
  State<_IntInput> createState() => _IntInputState();
}

class _IntInputState extends State<_IntInput> {
  final _controller = TextEditingController();

  void _submit() {
    final v = int.tryParse(_controller.text.trim());
    if (v == null) return;
    widget.onSubmit(v);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
            style: TaaevonTypography.mono.copyWith(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Answer',
              filled: true,
              fillColor: TaaevonColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TaaevonDimensions.radiusSm),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: TaaevonDimensions.sm),
        SizedBox(
          height: TaaevonDimensions.buttonHeight,
          child: ElevatedButton(onPressed: _submit, child: const Text('Solve')),
        ),
      ],
    );
  }
}
