import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_state.dart';
import 'model_state.dart';
import 'probe_state.dart';

/// Currently selected bottom navigation tab (0 = Analyse, 1 = History, 2 = Benchmark)
class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

/// Current active step in the 3-step Analyse flow (1, 2, 3)
class AnalyseStepNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      state = step;
    }
  }

  void nextStep() {
    if (state < 3) {
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

/// Tracks whether the active step view was opened directly from a record in the History tab.
class OpenedFromHistoryNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setFromHistory(bool value) => state = value;
}

final openedFromHistoryProvider =
    NotifierProvider<OpenedFromHistoryNotifier, bool>(OpenedFromHistoryNotifier.new);

/// Controller to navigate between steps and tabs in the FairScope flow
final navigationControllerProvider =
    Provider((ref) => NavigationController(ref));

class NavigationController {
  final Ref _ref;
  NavigationController(this._ref);

  void setTab(int index) {
    if (index == 0) {
      // Switching to Analyse tab from bottom nav always opens Step 1 cleanly
      _ref.read(analyseStepProvider.notifier).goToStep(1);
      _clearHistoryScanState();
    }
    _ref.read(openedFromHistoryProvider.notifier).setFromHistory(false);
    _ref.read(bottomNavIndexProvider.notifier).setTab(index);
  }

  void _clearHistoryScanState() {
    _ref.read(currentScanIdProvider.notifier).setId(null);
    _ref.read(analysisProvider.notifier).reset();
    _ref.read(selectedCaptureProvider.notifier).clear();
    _ref.read(selectedRecordProvider.notifier).clear();
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
    final openedFromHistory = _ref.read(openedFromHistoryProvider);

    if (currentTab == 1 || currentTab == 2) {
      // If on History or Benchmark tab, back returns to Analyse tab Step 1
      _ref.read(analyseStepProvider.notifier).goToStep(1);
      _ref.read(bottomNavIndexProvider.notifier).setTab(0);
      return true;
    }

    // If on Step 2 and this scan was opened from History, back returns directly to the History tab!
    if (currentStep == 2 && openedFromHistory) {
      _ref.read(openedFromHistoryProvider.notifier).setFromHistory(false);
      _ref.read(analyseStepProvider.notifier).goToStep(1);
      _ref.read(bottomNavIndexProvider.notifier).setTab(1);
      _clearHistoryScanState();
      return true;
    }

    if (currentStep > 1) {
      _ref.read(analyseStepProvider.notifier).previousStep();
      return true;
    }

    return false; // Let OS handle app exit from Step 1
  }
}
