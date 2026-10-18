import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/nav_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../features/analyse/connect/connect_screen.dart';
import '../../features/analyse/result/result_screen.dart';
import '../../features/analyse/explain/explain_screen.dart';
import '../../features/analyse/performance/performance_screen.dart';
import '../../features/history/history_screen.dart';

/// Main navigation shell managing the 2 tabs and nested 4-step flow
class NavShell extends ConsumerWidget {
  const NavShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(bottomNavIndexProvider);
    final currentStep = ref.watch(analyseStepProvider);
    final navController = ref.read(navigationControllerProvider);

    // Bottom navigation is hidden inside Analyse steps 2 to 4
    final showBottomNav = currentTab == 1 || (currentTab == 0 && currentStep == 1);

    return PopScope(
      canPop: currentTab == 0 && currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navController.handleBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentTab,
          children: [
            // Analyse Tab Flow (Steps 1 to 4)
            _buildAnalyseFlow(currentStep),
            // History Tab
            const HistoryScreen(),
          ],
        ),
        bottomNavigationBar: showBottomNav
            ? Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: NavigationBar(
                  height: AppSpacing.bottomNavHeight,
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primaryContainer,
                  selectedIndex: currentTab,
                  onDestinationSelected: (index) {
                    navController.setTab(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.sensors_outlined, color: AppColors.secondaryText),
                      selectedIcon: Icon(Icons.sensors_rounded, color: AppColors.primary),
                      label: 'Analyse',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_outlined, color: AppColors.secondaryText),
                      selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
                      label: 'History',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAnalyseFlow(int currentStep) {
    switch (currentStep) {
      case 1:
        return const ConnectScreen();
      case 2:
        return const ResultScreen();
      case 3:
        return const ExplainScreen();
      case 4:
        return const PerformanceScreen();
      default:
        return const ConnectScreen();
    }
  }
}

