import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the user has agreed to research consent during onboarding
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // First launch starts with onboarding

  void agreeAndContinue() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

