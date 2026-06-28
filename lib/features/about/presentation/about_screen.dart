import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';

/// Counts loaded from the bundled seed data so the figures shown can never drift
/// from what actually ships.
typedef _Stats = ({int facts, int words, int targets});

Future<_Stats> _loadStats() async {
  final factsRaw = await rootBundle.loadString('assets/data/facts_seed.json');
  final lexRaw = await rootBundle.loadString('assets/data/lexicon_seed.json');
  final facts = (json.decode(factsRaw) as List).length;
  final lex = json.decode(lexRaw) as Map<String, dynamic>;
  final words = (lex['words'] as List).cast<Map<String, dynamic>>();
  final targets = words.map((w) => w['target_language']).toSet().length;
  return (facts: facts, words: words.length, targets: targets);
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ABOUT', style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('about'),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            children: [
              const Center(
                child: Text('TAAEVON', style: TaaevonTypography.display),
              ),
              const SizedBox(height: TaaevonDimensions.xs),
              const Center(
                child: Text(
                  'Two minds, one path.',
                  style: TaaevonTypography.label,
                ),
              ),
              const SizedBox(height: TaaevonDimensions.xl),
              const _Section(
                title: 'A distraction-free design',
                body: 'Taaevon uses Abstract Geometric Minimalism: faded polygons '
                    'and isometric grids, high-contrast interactive colours, and '
                    'strictly no characters, mascots, or faces — so nothing '
                    'competes with the ideas themselves.',
              ),
              const _Section(
                title: 'Two curricula, interlocked',
                body: 'Mathematics from first counting to advanced calculus, and '
                    'language from your very first word to fluent conversation. '
                    'A difficulty engine can even pose advanced maths using '
                    'beginner-script number-words.',
              ),
              const _Section(
                title: 'No dead time',
                body: 'Every loading moment surfaces a verified, cross-disciplinary '
                    'fact, so even transitions teach you something.',
              ),
              const SizedBox(height: TaaevonDimensions.sm),
              FutureBuilder<_Stats>(
                future: _loadStats(),
                builder: (context, snapshot) {
                  final s = snapshot.data;
                  return _StatsCard(
                    facts: s?.facts,
                    words: s?.words,
                    targets: s?.targets,
                  );
                },
              ),
              const SizedBox(height: TaaevonDimensions.lg),
              Center(
                child: Text(
                  'Facts cite verified institutional sources.\n'
                  'Built with Flutter.',
                  textAlign: TextAlign.center,
                  style: TaaevonTypography.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TaaevonDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TaaevonTypography.heading.copyWith(fontSize: 18)),
          const SizedBox(height: TaaevonDimensions.xs),
          Text(body, style: TaaevonTypography.body),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({this.facts, this.words, this.targets});
  final int? facts;
  final int? words;
  final int? targets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaaevonDimensions.lg),
      decoration: BoxDecoration(
        color: TaaevonColors.cardBackground,
        borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
        border: Border.all(color: TaaevonColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: facts, label: 'facts'),
          _Stat(value: words, label: 'words'),
          _Stat(value: targets, label: 'languages'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value?.toString() ?? '—',
          style: TaaevonTypography.display.copyWith(
            fontSize: 28,
            letterSpacing: 0,
            fontFamily: TaaevonTypography.fontFamilyMono,
            color: TaaevonColors.primaryAction,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TaaevonTypography.label),
      ],
    );
  }
}
