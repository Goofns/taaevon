import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../activity_engine/polygon_polyglot/presentation/polygon_polyglot_screen.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../../review/presentation/review_screen.dart';
import '../data/lexicon_repository.dart';
import '../domain/language_catalog.dart';

/// Lets the learner choose which target language to practise. The list is
/// derived from the languages actually present in the lexicon, so it stays in
/// sync with the seeded data (currently Spanish and Japanese).
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key, this.repository});

  final LexiconRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? LexiconRepository.production();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CHOOSE A LANGUAGE', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('language-select'),
        child: SafeArea(
          child: FutureBuilder<List<String>>(
            future: repo.all().then(LanguageCatalog.distinctTargets),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TaaevonColors.languageAccent,
                  ),
                );
              }
              final codes = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(TaaevonDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tap a language to play or review.',
                      style: TaaevonTypography.label,
                    ),
                    const SizedBox(height: TaaevonDimensions.md),
                    Wrap(
                      spacing: TaaevonDimensions.md,
                      runSpacing: TaaevonDimensions.md,
                      children: [
                        for (final code in codes)
                          _LanguageTile(
                            option: LanguageCatalog.option(code),
                            onTap: () => _showLanguageOptions(context, code),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showLanguageOptions(BuildContext context, String code) {
  final option = LanguageCatalog.option(code);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: TaaevonColors.backgroundAlt,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(TaaevonDimensions.md),
            child: Text(
              '${option.nativeName}  ·  ${option.name}',
              style: TaaevonTypography.heading.copyWith(fontSize: 18),
            ),
          ),
          ListTile(
            title: const Text('Play Polygon Polyglot'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PolygonPolyglotScreen(targetLanguage: code),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Review vocabulary'),
            subtitle: const Text('Spaced repetition for words due today'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReviewScreen(targetLanguage: code),
                ),
              );
            },
          ),
          const SizedBox(height: TaaevonDimensions.sm),
        ],
      ),
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.option, required this.onTap});

  final LanguageOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${option.name}, ${option.nativeName}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
          child: Container(
            width: 152,
            height: 152,
            padding: const EdgeInsets.all(TaaevonDimensions.md),
            decoration: BoxDecoration(
              color: TaaevonColors.cardBackground,
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
              border: Border.all(color: TaaevonColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Center(
                    child: CustomPaint(
                      size: Size(44, 44),
                      painter: _HexPainter(),
                    ),
                  ),
                ),
                Text(
                  option.nativeName,
                  style: TaaevonTypography.heading.copyWith(
                    fontSize: 18,
                    color: TaaevonColors.languageAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(option.name, style: TaaevonTypography.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  const _HexPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..color = TaaevonColors.languageAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final points = <Offset>[
      for (var i = 0; i < 6; i++)
        center +
            Offset.fromDirection((2 * math.pi * i / 6) - math.pi / 2, radius),
    ];
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }

  @override
  bool shouldRepaint(_HexPainter old) => false;
}
