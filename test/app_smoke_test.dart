import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taaevon/main.dart';

/// Widget smoke tests that pump the REAL app — root cubits, the FactBloc loading
/// facts_seed.json from the real asset bundle, RootGate, and the first screen.
/// This is the integration surface the stub-based unit tests never touch: a
/// missing asset declaration, a boot-time exception, or a broken first screen
/// fails here in CI instead of on a device.
void main() {
  testWidgets('boots to onboarding for a new user, no exceptions',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TaaevonApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget); // onboarding CTA
  });

  testWidgets('boots straight to home for a returning user', (tester) async {
    SharedPreferences.setMockInitialValues({
      'taaevon.settings':
          '{"dailyGoal":5,"reduceMotion":false,"onboardingSeen":true}',
    });
    await tester.pumpWidget(const TaaevonApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('MATHEMATICS'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
  });

  testWidgets('a corrupt settings value still boots (no spinner wedge)',
      (tester) async {
    // Regression for the corrupt-prefs hang: even with garbage stored, hydrate
    // must mark hydrated:true so RootGate leaves its loader.
    SharedPreferences.setMockInitialValues({'taaevon.settings': '{not json'});
    await tester.pumpWidget(const TaaevonApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Falls back to defaults -> new-user onboarding, not a permanent spinner.
    expect(find.text('Get started'), findsOneWidget);
  });
}
