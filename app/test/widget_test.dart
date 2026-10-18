import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/main.dart';

void main() {
  testWidgets('Task 1 & 2 Verification: Onboarding consent unlocks app, tabs switch, steps move forward and back', (WidgetTester tester) async {
    // Configure test viewport
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Pump the FairScopeApp wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FairScopeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Verify Onboarding / Consent Screen is shown on first launch
    expect(find.text('Your data and privacy'), findsOneWidget);
    expect(find.text('Data is used for research only'), findsOneWidget);
    expect(find.text('I understand and agree'), findsOneWidget);

    // Checkbox is initially unchecked
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    final checkbox = tester.widget<Checkbox>(checkboxFinder);
    expect(checkbox.value, isFalse);

    // Continue button is initially disabled
    final continueBtnFinder = find.widgetWithText(FilledButton, 'Continue');
    expect(continueBtnFinder, findsOneWidget);
    final continueBtn = tester.widget<FilledButton>(continueBtnFinder);
    expect(continueBtn.onPressed, isNull);

    // 3. Tap Checkbox to agree
    await tester.tap(find.text('I understand and agree'));
    await tester.pumpAndSettle();

    // Now Continue button is enabled
    final enabledContinueBtn = tester.widget<FilledButton>(continueBtnFinder);
    expect(enabledContinueBtn.onPressed, isNotNull);

    // 4. Tap Continue to unlock the app
    await tester.tap(continueBtnFinder);
    await tester.pumpAndSettle();

    // 5. Verify Step 1 is now visible
    expect(find.text('Step 1 of 4: Connect'), findsOneWidget);
    expect(find.text('Probe connected'), findsOneWidget);
    // Verify bottom nav destinations exist
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Analyse'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('History'),
      ),
      findsOneWidget,
    );

    // 6. Simulate device button press to add a pending capture card
    final simulateBtn = find.text('Simulate device button [Mock hardware]');
    expect(simulateBtn, findsOneWidget);
    await tester.tap(simulateBtn);
    await tester.pumpAndSettle();

    // Verify card is added
    expect(find.text('1 of 5 stored'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);

    // Tap 'Analyse' button on the pending capture card to go to Step 2
    final analyseBtn = find.widgetWithText(FilledButton, 'Analyse');
    expect(analyseBtn, findsOneWidget);
    await tester.tap(analyseBtn);
    await tester.pumpAndSettle();

    // 7. Verify Step 2 is displayed
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    // Verify bottom nav is now HIDDEN
    expect(find.byType(NavigationBar), findsNothing);

    // 8. Tap 'Explain' button to go to Step 3
    final explainBtn = find.widgetWithText(FilledButton, 'Explain');
    expect(explainBtn, findsOneWidget);
    await tester.ensureVisible(explainBtn);
    await tester.pumpAndSettle();
    await tester.tap(explainBtn);
    await tester.pumpAndSettle();

    // 9. Verify Step 3 is displayed
    expect(find.text('Explanation'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 10. Tap 'Model performance' to go to Step 4
    final performanceBtn = find.widgetWithText(OutlinedButton, 'Model performance');
    expect(performanceBtn, findsOneWidget);
    await tester.ensureVisible(performanceBtn);
    await tester.pumpAndSettle();
    await tester.tap(performanceBtn);
    await tester.pumpAndSettle();

    // 11. Verify Step 4 is displayed
    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 12. Tap back button to return to Step 3
    final backBtn = find.byIcon(Icons.arrow_back_rounded);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Explanation'), findsOneWidget);

    // 13. Tap back button to return to Step 2
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Result'), findsOneWidget);

    // 14. Tap back button to return to Step 1
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4: Connect'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 15. Switch to History Tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('FS-0003'), findsOneWidget);
    expect(find.text('Search by ID or label'), findsOneWidget);
  });
}
