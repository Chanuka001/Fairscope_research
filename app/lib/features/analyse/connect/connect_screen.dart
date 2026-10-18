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

              // Probe status card with sensor.png
              Container(
                padding: AppSpacing.cardPaddingAll,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brMedium,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Image.asset(
                        'assets/images/sensor.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.sensors_rounded,
                          color: AppColors.primary,
                          size: 24.0,
                        ),
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
                      'Pending Captures (2/5)',
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

              // Capture Card 1: Avatar Type II
              _buildCaptureCard(
                context: context,
                avatarAsset: 'assets/images/avatas/user_avatar_type_II.png',
                timestamp: '18 Oct 2026 • 23:47',
                isNew: true,
                moisture: '42%',
                temp: '32.4°C',
                colorIdx: '68',
                onAnalyse: () => navController.goToStep(2),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Capture Card 2: Avatar Type IV
              _buildCaptureCard(
                context: context,
                avatarAsset: 'assets/images/avatas/user_avatar_type_IV.png',
                timestamp: '18 Oct 2026 • 23:40',
                isNew: false,
                moisture: '56%',
                temp: '33.1°C',
                colorIdx: '72',
                onAnalyse: () => navController.goToStep(2),
              ),

              const SizedBox(height: AppSpacing.s24),
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

  Widget _buildCaptureCard({
    required BuildContext context,
    required String avatarAsset,
    required String timestamp,
    required bool isNew,
    required String moisture,
    required String temp,
    required String colorIdx,
    required VoidCallback onAnalyse,
  }) {
    return Container(
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
              // Avatar Image Thumbnail
              Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.brMedium,
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.face_rounded,
                    size: 32.0,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isNew) ...[
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
                        ],
                        Flexible(
                          child: Text(
                            timestamp,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                value: moisture,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorChip(
                icon: Icons.thermostat_outlined,
                label: 'Temp',
                value: temp,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorChip(
                icon: Icons.palette_outlined,
                label: 'Color Idx',
                value: colorIdx,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(),
          const SizedBox(height: AppSpacing.s12),

          // Card Action Buttons (Eye Icon + Delete Icon + Analyse Button)
          Row(
            children: [
              // View raw data button (Eye Icon)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48.0, 48.0),
                  maximumSize: const Size(48.0, 48.0),
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.brMedium,
                  ),
                ),
                onPressed: () {
                  _showRawDataModal(
                    context: context,
                    timestamp: timestamp,
                    moisture: moisture,
                    temp: temp,
                    colorIdx: colorIdx,
                  );
                },
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 20.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),

              // Delete button (Delete Icon)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48.0, 48.0),
                  maximumSize: const Size(48.0, 48.0),
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.brMedium,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Capture deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20.0,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),

              // Analyse Primary Button
              Expanded(
                child: FilledButton(
                  onPressed: onAnalyse,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Analyse'),
                      SizedBox(width: AppSpacing.s8),
                      Icon(Icons.arrow_forward_rounded, size: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRawDataModal({
    required BuildContext context,
    required String timestamp,
    required String moisture,
    required String temp,
    required String colorIdx,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.rExtraLarge),
      ),
      builder: (ctx) {
        return Padding(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Raw Capture Data', style: AppTextStyles.title),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              _buildRawDataRow('Probe Camera', 'ESP32-CAM (OV2640)'),
              _buildRawDataRow('Resolution', '640 x 480 JPEG'),
              _buildRawDataRow('Payload Size', '48.2 KB'),
              _buildRawDataRow('Captured At', timestamp),
              _buildRawDataRow('Transfer Latency', '142 ms'),
              const Divider(height: 24.0),
              _buildRawDataRow('Moisture Sensor', moisture),
              _buildRawDataRow('Temperature', temp),
              _buildRawDataRow('Spectral Index', colorIdx),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRawDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(
            value,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
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
