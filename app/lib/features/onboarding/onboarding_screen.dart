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

              // Prominent Brand Header: App Logo Emblem + Dual-Color "FairScope" Typography
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 58.0,
                    height: 58.0,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: AppShadows.level1,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'assets/icons/appLogo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary,
                        size: 36.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fair',
                          style: AppTextStyles.display.copyWith(
                            fontSize: 34.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Scope',
                          style: AppTextStyles.display.copyWith(
                            fontSize: 34.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Subtitle
              SizedBox(
                width: 310.0,
                child: Text(
                  'AI-powered facial skin analysis with a wireless probe, for research purposes',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // "Your data and privacy" Card (Refined, crisp and elevated)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.extraLarge),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data and privacy',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildPrivacyItem(
                      icon: Icons.science_rounded,
                      iconColor: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFF0F9FF),
                      borderColor: const Color(0xFFBAE6FD),
                      text: 'Data is used for research only',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildPrivacyItem(
                      icon: Icons.camera_alt_rounded,
                      iconColor: AppColors.primary,
                      bgColor: const Color(0xFFF0FDFA),
                      borderColor: const Color(0xFF99F6E4),
                      text: 'Images go from the probe to your phone and stay on your phone',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildPrivacyItem(
                      icon: Icons.lock_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFFAF5FF),
                      borderColor: const Color(0xFFE9D5FF),
                      text: 'Analysed scans are saved only on this phone. You can delete them at any time',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildPrivacyItem(
                      icon: Icons.info_rounded,
                      iconColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFFFBEB),
                      borderColor: const Color(0xFFFDE68A),
                      text: 'Do not enter real names in labels',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // "I understand and agree" Checkbox Row
              InkWell(
                onTap: () {
                  setState(() {
                    _agreed = !_agreed;
                  });
                },
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: Checkbox(
                          value: _agreed,
                          activeColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _agreed = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        'I understand and agree',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
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
                  minimumSize: const Size.fromHeight(52.0),
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

  Widget _buildPrivacyItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Icon(icon, size: 20.0, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                fontSize: 14.0,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
