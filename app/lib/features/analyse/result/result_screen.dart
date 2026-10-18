import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/model_state.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/state/probe_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 2: Result Summary (Owned by Member A + C)
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final capture = ref.read(selectedCaptureProvider);
      final currentPrediction = ref.read(analysisProvider).prediction;
      if (capture != null && currentPrediction == null) {
        ref.read(analysisProvider.notifier).analyseCapture(capture);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navController = ref.read(navigationControllerProvider);
    final selectedCapture = ref.watch(selectedCaptureProvider);
    final activeVariant = ref.watch(activeModelVariantProvider);
    final analysis = ref.watch(analysisProvider);

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
            Text('Result', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            Text('Step 2 of 4', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Face Region Photo Card
              Container(
                width: double.infinity,
                height: 230.0,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                clipBehavior: Clip.antiAlias,
                child: selectedCapture != null && selectedCapture.imageBytes.isNotEmpty
                    ? Image.memory(
                        selectedCapture.imageBytes,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.face_rounded,
                          size: 72.0,
                          color: AppColors.primary,
                        ),
                      )
                    : Image.asset(
                        'assets/images/avatas/user_avatar_type_II.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Column(
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
              ),
              const SizedBox(height: AppSpacing.s12),

              // Sensor Pills Row
              Row(
                children: [
                  _buildSensorPill(
                    icon: Icons.water_drop_rounded,
                    label: 'Moisture',
                    value: selectedCapture != null
                        ? '${selectedCapture.sensorReading.moisture.toStringAsFixed(1)}%'
                        : '42.0%',
                    bgColor: AppColors.sensorMoistureBg,
                    iconColor: AppColors.sensorMoistureIcon,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildSensorPill(
                    icon: Icons.device_thermostat_rounded,
                    label: 'Temperature',
                    value: selectedCapture != null
                        ? '${selectedCapture.sensorReading.temperature.toStringAsFixed(1)}°C'
                        : '32.4°C',
                    bgColor: AppColors.sensorTempBg,
                    iconColor: AppColors.sensorTempIcon,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildSensorPill(
                    icon: Icons.palette_outlined,
                    label: 'Color Index',
                    value: selectedCapture != null
                        ? '${selectedCapture.sensorReading.colorIndex}'
                        : '3',
                    bgColor: AppColors.sensorColorBg,
                    iconColor: AppColors.sensorColorIcon,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Model Variant Switcher Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Variant:',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'baseline_fp32', label: Text('FP32')),
                      ButtonSegment(value: 'quantized_int8', label: Text('INT8')),
                    ],
                    selected: {activeVariant},
                    onSelectionChanged: (set) {
                      final chosen = set.first;
                      ref.read(activeModelVariantProvider.notifier).setVariant(chosen);
                      if (selectedCapture != null) {
                        ref.read(analysisProvider.notifier).analyseCapture(
                              selectedCapture,
                              variant: chosen,
                            );
                      }
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Prediction Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: analysis.isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 32.0,
                              height: 32.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.0,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              'Running on-device inference ($activeVariant)...',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            'Predicted skin condition',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 13.0,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            analysis.prediction?.label ?? 'Normal (Healthy skin)',
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 22.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s16),

                          // Circular confidence gauge
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 86.0,
                                height: 86.0,
                                child: CircularProgressIndicator(
                                  value: analysis.prediction?.confidence ?? 0.88,
                                  strokeWidth: 6.0,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
                                  color: AppColors.primary,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    analysis.prediction?.formattedConfidence ?? '88%',
                                    style: AppTextStyles.title.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20.0,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    'confidence',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.0,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s16),

                          // Placeholder Model Tag (Mandatory per spec)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(AppRadii.small),
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
              const SizedBox(height: AppSpacing.s12),

              // Timing Pill
              if (analysis.inferenceMs != null || analysis.preprocessMs != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14.0, color: AppColors.secondaryText),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        'Preprocess: ${(analysis.preprocessMs ?? 0).toStringAsFixed(1)} ms  •  Inference: ${(analysis.inferenceMs ?? 0).toStringAsFixed(1)} ms',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.s20),

              // Primary Action: Explain Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(48.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
                onPressed: () => navController.goToStep(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Explain prediction',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    const Icon(Icons.arrow_forward_rounded, size: 18.0),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorPill({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13.0, color: iconColor),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.0,
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3.0),
            Text(
              value,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
