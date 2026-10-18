import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/onboarding_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Onboarding / Research Consent Screen (Screen 1 in UI Showcase - Owned by Member D)
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Logo & App Name
              Image.asset(
                'assets/images/logoWithName.png',
                height: 52.0,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco_rounded, color: AppColors.primary, size: 36.0),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'FairScope',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Text(
                  'AI-powered facial skin analysis with a wireless probe, for research purposes',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 14.0,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // "Your data and privacy" Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data and privacy',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildPrivacyItem(
                      icon: Icons.science_outlined,
                      text: 'Data is used for research only',
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildPrivacyItem(
                      icon: Icons.camera_alt_outlined,
                      text: 'Images go from the probe to your phone and stay on your phone',
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildPrivacyItem(
                      icon: Icons.lock_outline_rounded,
                      text: 'Analysed scans are saved only on this phone. You can delete them at any time',
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildPrivacyItem(
                      icon: Icons.info_outline_rounded,
                      text: 'Do not enter real names in labels',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // "I understand and agree" Checkbox Row
              InkWell(
                onTap: () {
                  setState(() {
                    _agreed = !_agreed;
                  });
                },
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreed,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _agreed = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        'I understand and agree',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Continue Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _agreed ? AppColors.primary : AppColors.disabledFill,
                  foregroundColor: _agreed ? AppColors.onPrimary : AppColors.disabledText,
                  minimumSize: const Size.fromHeight(48.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  elevation: 0,
                ),
                onPressed: _agreed
                    ? () {
                        ref.read(onboardingCompletedProvider.notifier).agreeAndContinue();
                      }
                    : null,
                child: Text(
                  'Continue',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.0, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                color: AppColors.text,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

