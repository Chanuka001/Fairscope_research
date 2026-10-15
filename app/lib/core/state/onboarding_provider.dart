import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod state notifier managing research participant onboarding consent.
class ConsentNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void grantConsent() {
    state = true;
  }

  void revokeConsent() {
    state = false;
  }
}

final consentProvider =
    NotifierProvider<ConsentNotifier, bool>(ConsentNotifier.new);

