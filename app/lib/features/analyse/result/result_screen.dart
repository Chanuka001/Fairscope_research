import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 2: Result Summary (Owned by Member A + C)
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => navController.handleBack(),
        ),
        title: Column(
          children: [
            Text('Result', style: AppTextStyles.title),
            Text('Step 2 of 4', style: AppTextStyles.caption),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s16),
            child: StepIndicator(currentStep: 2),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image container
              Container(
                width: double.infinity,
                height: 220.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.face_rounded,
                      size: 72.0,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppSpacing.s8),
                    Text(
                      'Captured Face Region (OV2640)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Sensor reading summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricBadge('Moisture', '42%'),
                  _buildMetricBadge('Temperature', '32.4°C'),
                  _buildMetricBadge('Color Index', '68'),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),

              // Analysis Card
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPaddingAll,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  children: [
                    Text(
                      'Predicted skin condition',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Normal skin',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Confidence ring indicator
                    Container(
                      width: 84.0,
                      height: 84.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 4.0,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '87%',
                              style: AppTextStyles.title.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'confidence',
                              style: AppTextStyles.caption.copyWith(fontSize: 10.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Placeholder Model Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadii.brSmall,
                      ),
                      child: Text(
                        'Placeholder model',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // Timing Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.brMedium,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 16.0,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Inference time: 320 ms',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // Explain Button
              FilledButton(
                onPressed: () {
                  navController.goToStep(3);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Explain'),
                    SizedBox(width: AppSpacing.s8),
                    Icon(Icons.arrow_forward_rounded, size: 18.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2.0),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

