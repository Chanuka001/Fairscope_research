import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairscope_app/main.dart';

void main() {
  testWidgets('Task 2: First launch shows onboarding, consent unlocks NavShell', (WidgetTester tester) async {
    // 1. Build app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FairScopeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Onboarding is displayed initially
    expect(find.text('Your data and privacy'), findsOneWidget);
    expect(find.text('Data is used for research only.'), findsOneWidget);
    expect(find.text('I understand and agree'), findsOneWidget);

    final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueFinder, findsOneWidget);

    // 3. Scroll if needed and tap consent checkbox
    final checkboxFinder = find.text('I understand and agree');
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // 4. Ensure Continue is visible in scroll view, then tap
    await tester.ensureVisible(continueFinder);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // 5. Main shell is now unlocked!
    expect(find.text('FairScope Scan'), findsOneWidget);
    expect(find.textContaining('Member A'), findsWidgets);

    // 6. Tabs switch properly
    await tester.tap(find.byIcon(Icons.sensors_outlined));
    await tester.pumpAndSettle();
    expect(find.text('IoT Sensor Probe'), findsOneWidget);
    expect(find.textContaining('Member B'), findsWidgets);
  });
}
