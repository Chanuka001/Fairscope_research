import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/state/probe_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 2: Result Summary (Owned by Member A + C)
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);
    final selectedCapture = ref.watch(selectedCaptureProvider);

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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s12),
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
                        : '42%',
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
                        : '68',
                    bgColor: AppColors.sensorColorBg,
                    iconColor: AppColors.sensorColorIcon,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Prediction Result Card matching Showcase Screen 4
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
                      'Normal skin',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.0,
                      ),
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
                            value: 0.87,
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
                              '87%',
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

                    // Placeholder Model Tag
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
              const SizedBox(height: AppSpacing.s20),

              // Explain Primary Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(48.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  navController.goToStep(3);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Explain',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    const Icon(Icons.arrow_forward_rounded, size: 18.0),
                  ],
                ),
              ),
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
