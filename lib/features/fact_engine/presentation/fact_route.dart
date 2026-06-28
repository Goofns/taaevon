import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../bloc/fact_bloc.dart';
import 'fact_interstitial_widget.dart';

/// Pushes [child] with a transition that cross-fades a micro-learning fact into
/// the destination — the loading-engine moment from PRD §6.3. A fresh fact is
/// requested from the root [FactBloc] just before navigating, so dead time on a
/// screen change is turned into a learning moment.
Future<T?> pushWithFact<T>(
  BuildContext context,
  Widget child, {
  int complexityLevel = 3,
}) {
  context.read<FactBloc>().add(FactRequested(complexityLevel: complexityLevel));
  return Navigator.of(context).push<T>(FactRoute<T>(child));
}

/// A page route whose transition shows a fact over a faint backdrop and then
/// cross-fades to the destination.
class FactRoute<T> extends PageRouteBuilder<T> {
  FactRoute(Widget page)
      : super(
          transitionDuration: const Duration(milliseconds: 650),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Destination fades in across the transition.
                FadeTransition(opacity: animation, child: child),
                // Fact card sits on top and fades out as the page arrives.
                FadeTransition(
                  opacity: ReverseAnimation(animation),
                  child: const IgnorePointer(
                    child: ColoredBox(
                      color: TaaevonColors.backgroundBase,
                      child: Center(child: FactInterstitial()),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}
