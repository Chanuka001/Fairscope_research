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
  double _heatmapOpacity = 0.65;

  @override
  Widget build(BuildContext context) {
    final navController = ref.read(navigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => navController.handleBack(),
        ),
        title: Column(
          children: [
            Text('Explanation', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            Text('Step 3 of 4', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heatmap visualizer container with face avatar
              Container(
                width: double.infinity,
                height: 250.0,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/avatas/user_avatar_type_II.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.face_rounded,
                        size: 96.0,
                        color: AppColors.primary,
                      ),
                    ),
                    // Realistic Grad-CAM saliency heat overlay
                    Opacity(
                      opacity: _heatmapOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.2, 0.1),
                            radius: 0.55,
                            colors: [
                              Colors.redAccent.withValues(alpha: 0.85),
                              Colors.orangeAccent.withValues(alpha: 0.65),
                              Colors.yellowAccent.withValues(alpha: 0.40),
                              Colors.tealAccent.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.60, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.s12,
                      right: AppSpacing.s12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppRadii.small),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Grad-CAM Heatmap',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Heatmap opacity',
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_heatmapOpacity * 100).toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('0%', style: AppTextStyles.caption.copyWith(fontSize: 11.0)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.primary,
                              trackHeight: AppSpacing.sliderTrackHeight,
                            ),
                            child: Slider(
                              value: _heatmapOpacity,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() {
                                  _heatmapOpacity = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Text('100%', style: AppTextStyles.caption.copyWith(fontSize: 11.0)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // "Why this result?" Card
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
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          'Why this result?',
                          style: AppTextStyles.title.copyWith(fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadii.small),
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
                      'The model focused on the cheek and T-zone areas, which are often related to moisture and texture changes in the skin.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14.0,
                        height: 1.5,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // Model Performance Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48.0),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
                onPressed: () {
                  navController.goToStep(4);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 20.0, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Model performance',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    'Research view',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryContainer,
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
