import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/onboarding_provider.dart';
import '../../core/theme/app_colors.dart';

/// Onboarding & Participant Consent Screen
/// Owned by Member D: AI: Explainability, Fairness & Consent Flow
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Logo
                Center(
                  child: Image.asset(
                    'assets/images/logoWithName.png',
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.medical_services_outlined,
                        size: 80,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  'AI-powered facial skin analysis using your camera and a skin sensor for research purposes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 28),

                // Data and privacy card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your data and privacy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Member D',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildPrivacyItem(
                          icon: Icons.science_outlined,
                          text: 'Data is used for research only.',
                        ),
                        const SizedBox(height: 16),
                        _buildPrivacyItem(
                          icon: Icons.verified_user_outlined,
                          text: 'Images stay on your device.',
                        ),
                        const SizedBox(height: 16),
                        _buildPrivacyItem(
                          icon: Icons.person_outline_rounded,
                          text: 'You can withdraw at any time.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Checkbox row
                InkWell(
                  onTap: () {
                    setState(() {
                      _agreed = !_agreed;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _agreed = val ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'I understand and agree',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Continue Button
                ElevatedButton(
                  onPressed: _agreed
                      ? () {
                          ref.read(consentProvider.notifier).grantConsent();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreed ? AppColors.primary : AppColors.disabledFill,
                    foregroundColor: _agreed ? AppColors.onPrimary : AppColors.disabledText,
                    disabledBackgroundColor: AppColors.disabledFill,
                    disabledForegroundColor: AppColors.disabledText,
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

