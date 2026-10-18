import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/nav_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FairScopeApp(),
    ),
  );
}

class FairScopeApp extends StatelessWidget {
  const FairScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NavShell(),
    );
  }
}
