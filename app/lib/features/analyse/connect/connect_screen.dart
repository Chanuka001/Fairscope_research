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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean top header matching FairScope UI Showcase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 20.0, color: AppColors.text),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Step 1 of 4: Connect',
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const StepIndicator(currentStep: 1),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Probe connected status pill (Compact, elegant pill matching Screen 3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.0,
                      height: 32.0,
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/sensor.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.sensors_rounded,
                          color: AppColors.primary,
                          size: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Row(
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
                    ),
                    // Signal and Battery
                    Row(
                      children: [
                        const Icon(
                          Icons.signal_cellular_alt_rounded,
                          size: 16.0,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        const Icon(
                          Icons.battery_5_bar_rounded,
                          size: 16.0,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '78%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Section title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Captures',
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadii.small),
                    ),
                    child: Text(
                      '2 of 5 stored',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Capture Card 1: Avatar Type II (FairScope UI Showcase Screen 3)
              _buildCaptureCard(
                context: context,
                avatarAsset: 'assets/images/avatas/user_avatar_type_II.png',
                timestamp: '16 Sep 2026 • 14:32',
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
                timestamp: '16 Sep 2026 • 13:47',
                isNew: false,
                moisture: '56%',
                temp: '33.1°C',
                colorIdx: '72',
                onAnalyse: () => navController.goToStep(2),
              ),

              const SizedBox(height: AppSpacing.s20),
              Center(
                child: Text(
                  'Up to 5 captures are kept. Older ones are removed.',
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondaryText,
                  ),
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
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Image Thumbnail
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
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
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                        ],
                        Flexible(
                          child: Text(
                            timestamp,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'OV2640 Image • 640×480 JPEG',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          // 3 Sensor pills with individual pastel colors
          Row(
            children: [
              _buildSensorPill(
                icon: Icons.water_drop_rounded,
                label: 'Moisture',
                value: moisture,
                bgColor: AppColors.sensorMoistureBg,
                iconColor: AppColors.sensorMoistureIcon,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorPill(
                icon: Icons.device_thermostat_rounded,
                label: 'Temperature',
                value: temp,
                bgColor: AppColors.sensorTempBg,
                iconColor: AppColors.sensorTempIcon,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorPill(
                icon: Icons.palette_outlined,
                label: 'Color Index',
                value: colorIdx,
                bgColor: AppColors.sensorColorBg,
                iconColor: AppColors.sensorColorIcon,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: AppSpacing.s12),

          // Action buttons: Eye Icon + Trash Icon + Analyse Button
          Row(
            children: [
              // Eye Icon Button (View raw data)
              InkWell(
                onTap: () {
                  _showRawDataModal(
                    context: context,
                    timestamp: timestamp,
                    moisture: moisture,
                    temp: temp,
                    colorIdx: colorIdx,
                  );
                },
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.actionEyeBg,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.actionEyeBorder),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.visibility_outlined,
                      size: 20.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),

              // Delete Icon Button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Capture deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.actionDeleteBg,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.actionDeleteBorder),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),

              // Analyse Primary Button (Matches Showcase with rounded pill)
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(44.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onAnalyse,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Analyse',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      const Icon(Icons.arrow_forward_rounded, size: 16.0),
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
              _buildRawDataRow('Resolution', '640 × 480 JPEG'),
              _buildRawDataRow('Payload Size', '48.2 KB'),
              _buildRawDataRow('Captured At', timestamp),
              _buildRawDataRow('Transfer Latency', '142 ms'),
              const Divider(height: 24.0, color: AppColors.border),
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
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          Text(
            value,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
