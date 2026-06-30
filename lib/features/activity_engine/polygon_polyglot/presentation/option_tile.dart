import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/typography.dart';
import '../domain/polyglot_round.dart';

/// A tappable geometric tile showing a candidate translation. No iconography —
/// the target script and its romanization carry the content.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.option,
    required this.targetLanguage,
    required this.onTap,
  });

  final PolyglotOption option;

  /// Language code of [option].text (e.g. 'ja') — tags the foreign script with
  /// its language for correct glyph selection and screen-reader pronunciation
  /// (WCAG 3.1.2 Language of Parts).
  final String targetLanguage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: option.romanization == null
          ? option.text
          : '${option.text}, ${option.romanization}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(
              horizontal: TaaevonDimensions.md,
              vertical: TaaevonDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: TaaevonColors.cardBackground,
              borderRadius: BorderRadius.circular(TaaevonDimensions.radiusMd),
              border: Border.all(color: TaaevonColors.inputBorder, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.text,
                  textAlign: TextAlign.center,
                  locale: Locale(targetLanguage),
                  style: TaaevonTypography.heading.copyWith(fontSize: 20),
                ),
                if (option.romanization != null) ...[
                  const SizedBox(height: 2),
                  Text(option.romanization!, style: TaaevonTypography.label),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
