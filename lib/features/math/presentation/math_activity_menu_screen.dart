import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../activity_engine/isometric_tessellation/presentation/isometric_tessellation_screen.dart';
import '../../activity_engine/matrix_vector_track/presentation/matrix_vector_track_screen.dart';
import '../../background/background_seed_generator.dart';
import '../../background/geometric_background_painter.dart';
import '../domain/math_domain.dart';
import 'math_screen.dart';

/// The activities a math domain offers (PRD §7.3). Only the built secondary
/// activities are mapped; domains whose spec'd secondary isn't implemented yet
/// (number line, differential-equation tiles, etc.) simply offer problem solving.
enum _Secondary { tessellation, vector }

const Map<String, _Secondary> _secondaryByDomain = {
  'arithmetic': _Secondary.tessellation,
  'fractions': _Secondary.tessellation,
  'geometry': _Secondary.tessellation,
  'algebra': _Secondary.vector,
  'trigonometry': _Secondary.vector,
  'linear-algebra': _Secondary.vector,
};

/// Activity menu for a single math [domain] (PRD §7.2: "tapping a tile navigates
/// to the domain's activity menu"). Routes problem solving + the domain's built
/// secondary activity, both at the domain's band.
class MathActivityMenuScreen extends StatelessWidget {
  const MathActivityMenuScreen({
    super.key,
    required this.domain,
    this.targetLanguage = 'ja',
  });

  final MathDomain domain;
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final secondary = _secondaryByDomain[domain.id];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(domain.name.toUpperCase(), style: TaaevonTypography.label),
      ),
      extendBodyBehindAppBar: true,
      body: GeometricBackground(
        seed: BackgroundSeedGenerator.fromUserId('menu-${domain.id}'),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            children: [
              Text('Choose an activity', style: TaaevonTypography.label),
              const SizedBox(height: TaaevonDimensions.md),
              _ActivityCard(
                title: 'Solve problems',
                subtitle: 'Adaptive problems at your level',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MathScreen(
                      band: domain.band,
                      targetLanguage: targetLanguage,
                    ),
                  ),
                ),
              ),
              if (secondary == _Secondary.tessellation) ...[
                const SizedBox(height: TaaevonDimensions.md),
                _ActivityCard(
                  title: 'Isometric Tessellation',
                  subtitle: 'Solve to earn tiles and build patterns',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IsometricTessellationScreen(),
                    ),
                  ),
                ),
              ],
              if (secondary == _Secondary.vector) ...[
                const SizedBox(height: TaaevonDimensions.md),
                _ActivityCard(
                  title: 'Matrix Vector Track',
                  subtitle: 'Steer a vector across the grid',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatrixVectorTrackScreen(
                        targetLanguage: targetLanguage,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(TaaevonDimensions.lg),
            decoration: BoxDecoration(
              color: TaaevonColors.cardBackground,
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusLg),
              border: Border.all(color: TaaevonColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TaaevonTypography.heading.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TaaevonTypography.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
