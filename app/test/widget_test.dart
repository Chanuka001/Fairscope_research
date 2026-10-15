import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairscope_app/main.dart';

void main() {
  testWidgets('Task 1: Navigation shell switches tabs and shows owner labels', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FairScopeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tab 1: Scan tab is visible initially with Member A's label
    expect(find.text('FairScope Scan'), findsOneWidget);
    expect(find.textContaining('Member A'), findsWidgets);

    // Switch to Tab 2: Sensor
    await tester.tap(find.byIcon(Icons.sensors_outlined));
    await tester.pumpAndSettle();
    expect(find.text('IoT Sensor Probe'), findsOneWidget);
    expect(find.textContaining('Member B'), findsWidgets);

    // Switch to Tab 3: Compare (Member C)
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Model Comparison'), findsOneWidget);
    expect(find.textContaining('Member C (Monal)'), findsWidgets);

    // Switch to Tab 4: Explain (Member D)
    await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Explainability & Fairness'), findsOneWidget);
    expect(find.textContaining('Member D'), findsWidgets);
  });
}
