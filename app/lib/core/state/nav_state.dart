import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently selected bottom navigation tab (0 = Analyse, 1 = History)
class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

/// Current active step in the 4-step Analyse flow (1, 2, 3, 4)
class AnalyseStepNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      state = step;
    }
  }

  void nextStep() {
    if (state < 4) {
      state = state + 1;
    }
  }

  void previousStep() {
    if (state > 1) {
      state = state - 1;
    }
  }

  void reset() {
    state = 1;
  }
}

final analyseStepProvider =
    NotifierProvider<AnalyseStepNotifier, int>(AnalyseStepNotifier.new);

/// Controller to navigate between steps and tabs in the FairScope flow
final navigationControllerProvider =
    Provider((ref) => NavigationController(ref));

class NavigationController {
  final Ref _ref;
  NavigationController(this._ref);

  void setTab(int index) {
    _ref.read(bottomNavIndexProvider.notifier).setTab(index);
  }

  void goToStep(int step) {
    _ref.read(analyseStepProvider.notifier).goToStep(step);
  }

  void nextStep() {
    _ref.read(analyseStepProvider.notifier).nextStep();
  }

  bool handleBack() {
    final currentStep = _ref.read(analyseStepProvider);
    final currentTab = _ref.read(bottomNavIndexProvider);

    if (currentTab == 1) {
      // If on History tab, back returns to Analyse tab
      _ref.read(bottomNavIndexProvider.notifier).setTab(0);
      return true;
    }

    if (currentStep > 1) {
      _ref.read(analyseStepProvider.notifier).previousStep();
      return true;
    }

    return false; // Let OS handle app exit from Step 1
  }
}
