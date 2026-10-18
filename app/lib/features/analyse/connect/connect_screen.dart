import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 1: Connect probe and view pending captures (Owned by Member B + C)
class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 1 of 4: Connect',
                          style: AppTextStyles.headline,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Wireless probe status & captures',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  const StepIndicator(currentStep: 1),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Probe status card
              Container(
                padding: AppSpacing.cardPaddingAll,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sensors_rounded,
                      color: AppColors.primary,
                      size: AppSpacing.iconLarge,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Flexible(
                                child: Text(
                                  'Probe connected',
                                  style: AppTextStyles.label.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Mock probe active • Battery 78%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: AppSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brSmall,
                      ),
                      child: Text(
                        'Mock data',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Section title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pending Captures (1/5)',
                      style: AppTextStyles.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Newest first',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Placeholder Capture Card
              Container(
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
                        // Thumbnail placeholder
                        Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.brMedium,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.face_rounded,
                            size: 32.0,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s8,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: AppRadii.brExtraSmall,
                                    ),
                                    child: Text(
                                      'NEW',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Text(
                                    '18 Oct 2026 • 23:40',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                'OV2640 Image • 640x480 JPEG',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Sensor chips row
                    Row(
                      children: [
                        _buildSensorChip(
                          icon: Icons.water_drop_outlined,
                          label: 'Moisture',
                          value: '42%',
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        _buildSensorChip(
                          icon: Icons.thermostat_outlined,
                          label: 'Temp',
                          value: '32.4°C',
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        _buildSensorChip(
                          icon: Icons.palette_outlined,
                          label: 'Color Idx',
                          value: '68',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s8),

                    // Card Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('View raw'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            onPressed: () {},
                            child: const Text('Delete'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () {
                              navController.goToStep(2);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Analyse'),
                                SizedBox(width: AppSpacing.s4),
                                Icon(Icons.arrow_forward_rounded, size: 16.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),
              // Helper text
              Center(
                child: Text(
                  'Up to 5 captures are kept in memory. Older ones are removed.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppRadii.brMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14.0, color: AppColors.primary),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(fontSize: 10.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              value,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

