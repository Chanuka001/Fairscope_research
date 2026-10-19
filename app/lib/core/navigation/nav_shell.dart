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
class NavShell extends ConsumerStatefulWidget {
  const NavShell({super.key});

  @override
  ConsumerState<NavShell> createState() => _NavShellState();
}

class _NavShellState extends ConsumerState<NavShell> {
  int _lastStep = 1;

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(bottomNavIndexProvider);
    final currentStep = ref.watch(analyseStepProvider);
    final navController = ref.read(navigationControllerProvider);

    final isForward = currentStep >= _lastStep;
    _lastStep = currentStep;

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
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: currentTab == 0
              ? KeyedSubtree(
                  key: const ValueKey('tab_analyse'),
                  child: _buildAnalyseFlow(currentStep, isForward),
                )
              : const KeyedSubtree(
                  key: ValueKey('tab_history'),
                  child: HistoryScreen(),
                ),
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

  Widget _buildAnalyseFlow(int currentStep, bool isForward) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isIncoming = (child.key as ValueKey<int>?)?.value == currentStep;
        if (isIncoming) {
          final inOffset = Tween<Offset>(
            begin: isForward ? const Offset(0.18, 0.0) : const Offset(-0.18, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          final inFade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
          );
          return SlideTransition(
            position: inOffset,
            child: FadeTransition(
              opacity: inFade,
              child: child,
            ),
          );
        } else {
          final outOffset = Tween<Offset>(
            begin: isForward ? const Offset(-0.08, 0.0) : const Offset(0.08, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInCubic,
          ));
          final outFade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
          );
          return SlideTransition(
            position: outOffset,
            child: FadeTransition(
              opacity: outFade,
              child: child,
            ),
          );
        }
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentStep),
        child: _stepWidget(currentStep),
      ),
    );
  }

  Widget _stepWidget(int step) {
    switch (step) {
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

