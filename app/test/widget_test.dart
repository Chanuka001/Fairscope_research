import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairscope_app/main.dart';

void main() {
  testWidgets('Task 4: Sensor tab displays live simulated telemetry and probe status', (WidgetTester tester) async {
    // 1. Build app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FairScopeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Agree to onboarding consent
    final checkboxFinder = find.text('I understand and agree');
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.ensureVisible(continueFinder);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // 3. Switch to Sensor Tab
    final sensorTab = find.byIcon(Icons.sensors_outlined);
    await tester.tap(sensorTab);
    await tester.pumpAndSettle();

    // 4. Verify Task 4 elements
    expect(find.text('Using mock data'), findsOneWidget);
    expect(find.text('FairScope Probe'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Moisture'), findsOneWidget);
    expect(find.text('Skin temperature'), findsOneWidget);
    expect(find.text('Color index'), findsOneWidget);

    // 5. Verify Disconnect interaction
    final disconnectBtn = find.text('Disconnect');
    expect(disconnectBtn, findsOneWidget);
    await tester.tap(disconnectBtn);
    await tester.pumpAndSettle();

    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
