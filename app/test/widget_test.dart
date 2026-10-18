import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/main.dart';

void main() {
  testWidgets('Task 1 Verification: Tabs switch, steps move forward and back, tabs hidden in steps 2-4', (WidgetTester tester) async {
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

    // 2. Verify Step 1 is visible initially
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

    // 3. Tap 'Analyse' button on the pending capture card to go to Step 2
    final analyseBtn = find.widgetWithText(FilledButton, 'Analyse');
    expect(analyseBtn, findsWidgets);
    await tester.tap(analyseBtn.first);
    await tester.pumpAndSettle();

    // 4. Verify Step 2 is displayed
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    // Verify bottom nav is now HIDDEN
    expect(find.byType(NavigationBar), findsNothing);

    // 5. Tap 'Explain' button to go to Step 3
    final explainBtn = find.widgetWithText(FilledButton, 'Explain');
    expect(explainBtn, findsOneWidget);
    await tester.ensureVisible(explainBtn);
    await tester.pumpAndSettle();
    await tester.tap(explainBtn);
    await tester.pumpAndSettle();

    // 6. Verify Step 3 is displayed
    expect(find.text('Explanation'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 7. Tap 'Model performance' to go to Step 4
    final performanceBtn = find.widgetWithText(OutlinedButton, 'Model performance');
    expect(performanceBtn, findsOneWidget);
    await tester.ensureVisible(performanceBtn);
    await tester.pumpAndSettle();
    await tester.tap(performanceBtn);
    await tester.pumpAndSettle();

    // 8. Verify Step 4 is displayed
    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // 9. Tap back button to return to Step 3
    final backBtn = find.byIcon(Icons.arrow_back_rounded);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Explanation'), findsOneWidget);

    // 10. Tap back button to return to Step 2
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Result'), findsOneWidget);

    // 11. Tap back button to return to Step 1
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4: Connect'), findsOneWidget);
    // Bottom nav should be visible again
    expect(find.byType(NavigationBar), findsOneWidget);

    // 12. Switch to History Tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('FS-0003'), findsOneWidget);
    expect(find.text('Search by ID or label'), findsOneWidget);
  });
}
