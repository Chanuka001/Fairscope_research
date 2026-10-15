import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/sensor/sensor_screen.dart';
import '../../features/comparison/comparison_screen.dart';
import '../../features/explain/explain_screen.dart';

/// Riverpod 3.x notifier for active bottom navigation tab.
class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) {
    state = index;
  }
}

final activeTabProvider =
    NotifierProvider<ActiveTabNotifier, int>(ActiveTabNotifier.new);

/// Main shell managing bottom navigation bar and page switching.
class NavShell extends ConsumerWidget {
  const NavShell({super.key});

  static const List<Widget> _screens = [
    ScanScreen(),
    SensorScreen(),
    ComparisonScreen(),
    ExplainScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (index) {
          ref.read(activeTabProvider.notifier).selectTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt_rounded),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors_rounded),
            label: 'Sensor',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline_rounded),
            selectedIcon: Icon(Icons.lightbulb_rounded),
            label: 'Explain',
          ),
        ],
      ),
    );
  }
}
