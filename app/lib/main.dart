import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/nav_shell.dart';
import 'core/state/onboarding_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FairScopeApp(),
    ),
  );
}

class FairScopeApp extends ConsumerWidget {
  const FairScopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasConsented = ref.watch(consentProvider);

    return MaterialApp(
      title: 'FairScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasConsented ? const NavShell() : const OnboardingScreen(),
    );
  }
}
