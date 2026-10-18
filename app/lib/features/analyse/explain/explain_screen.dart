import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 3: Grad-CAM Explanation (Owned by Member D)
class ExplainScreen extends ConsumerStatefulWidget {
  const ExplainScreen({super.key});

  @override
  ConsumerState<ExplainScreen> createState() => _ExplainScreenState();
}

class _ExplainScreenState extends ConsumerState<ExplainScreen> {
  double _heatmapOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
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
            Text('Explanation', style: AppTextStyles.title),
            Text('Step 3 of 4', style: AppTextStyles.caption),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s16),
            child: StepIndicator(currentStep: 3),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heatmap visualizer container
              Container(
                width: double.infinity,
                height: 240.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.face_rounded,
                      size: 96.0,
                      color: AppColors.primary,
                    ),
                    // Simulated heatmap overlay
                    Opacity(
                      opacity: _heatmapOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.brLarge,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.7,
                            colors: [
                              AppColors.heatmapHigh.withValues(alpha: 0.8),
                              AppColors.heatmapLow.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.s8,
                      right: AppSpacing.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: AppRadii.brSmall,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Grad-CAM Placeholder',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Heatmap Opacity Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Heatmap opacity', style: AppTextStyles.label),
                  Text('${(_heatmapOpacity * 100).toInt()}%', style: AppTextStyles.caption),
                ],
              ),
              Slider(
                value: _heatmapOpacity,
                min: 0.0,
                max: 1.0,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (val) {
                  setState(() {
                    _heatmapOpacity = val;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.s16),

              // Explanation Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text('Why this result?', style: AppTextStyles.title),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.brSmall,
                          ),
                          child: Text(
                            'Sample data',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'The model focused on the cheek and T-zone areas, which correlate strongly with moisture levels and surface textures typical of normal skin.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // Model Performance Button
              OutlinedButton(
                onPressed: () {
                  navController.goToStep(4);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 20.0),
                    SizedBox(width: AppSpacing.s8),
                    Text('Model performance'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadii.brSmall,
                  ),
                  child: Text(
                    'Research view (not part of real-world use)',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.0,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

