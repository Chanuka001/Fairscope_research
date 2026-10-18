import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/probe_config.dart';
import '../../../../core/models/capture.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/services/http_probe_service.dart';
import '../../../../core/services/probe_service.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/state/probe_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 1: Connect probe and view pending captures (Owned by Member B + C)
class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-connect probe on initial load per Section 2 flow
    Future.microtask(() {
      final status = ref.read(probeStatusProvider);
      if (status == ProbeConnectionStatus.off) {
        ref.read(probeStatusProvider.notifier).connect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navController = ref.read(navigationControllerProvider);
    final probeStatus = ref.watch(probeStatusProvider);
    final captures = ref.watch(pendingCapturesProvider);
    final isMockMode = ref.watch(isMockProbeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s12,
          ),
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

              // Probe connected status pill (Compact, elegant pill with animated state)
              _buildProbeStatusPill(context, probeStatus),
              const SizedBox(height: AppSpacing.s12),

              // Probe mode switcher (Mock hardware vs Real ESP32 probe)
              _buildModeSwitcher(isMockMode),
              const SizedBox(height: AppSpacing.s12),

              // Mock Hardware Simulate Button Control or Real Probe Control
              if (isMockMode)
                _buildSimulateButton(probeStatus)
              else
                _buildRealProbeControl(probeStatus),
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
                      '${captures.length} of ${ProbeConfig.maxPendingCaptures} stored',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Empty state or list of pending capture cards
              if (captures.isEmpty)
                _buildEmptyCapturesState(probeStatus)
              else
                ...captures.asMap().entries.map((entry) {
                  final index = entry.key;
                  final capture = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: _buildCaptureCard(
                      context: context,
                      capture: capture,
                      isNew: index == 0,
                      onAnalyse: () {
                        ref.read(selectedCaptureProvider.notifier).select(capture);
                        navController.goToStep(2);
                      },
                      onDelete: () => _confirmDelete(capture.id),
                    ),
                  );
                }),

              const SizedBox(height: AppSpacing.s16),
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
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  /// Probe hardware connection pill
  Widget _buildProbeStatusPill(BuildContext context, ProbeConnectionStatus status) {
    Color bg;
    Color border;
    Color dotColor;
    String statusText;
    late final Widget trailing;

    switch (status) {
      case ProbeConnectionStatus.connected:
        bg = AppColors.primaryContainer.withValues(alpha: 0.6);
        border = AppColors.primary.withValues(alpha: 0.25);
        dotColor = AppColors.success;
        statusText = 'Probe connected';
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.signal_cellular_alt_rounded, size: 16.0, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s4),
            const Icon(Icons.battery_5_bar_rounded, size: 16.0, color: AppColors.primary),
            const SizedBox(width: 4.0),
            Text(
              '82%',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            GestureDetector(
              onTap: () => ref.read(probeStatusProvider.notifier).disconnect(),
              child: Tooltip(
                message: 'Disconnect probe',
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.power_settings_new_rounded,
                    size: 13.0,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      case ProbeConnectionStatus.connecting:
        bg = AppColors.warningContainer.withValues(alpha: 0.5);
        border = AppColors.warning.withValues(alpha: 0.4);
        dotColor = AppColors.warning;
        statusText = 'Connecting to probe...';
        trailing = const SizedBox(
          width: 14.0,
          height: 14.0,
          child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.warning),
        );
        break;
      case ProbeConnectionStatus.off:
      case ProbeConnectionStatus.lost:
      case ProbeConnectionStatus.error:
        bg = AppColors.surfaceVariant;
        border = AppColors.border;
        dotColor = AppColors.error;
        statusText = status == ProbeConnectionStatus.off
            ? 'Probe disconnected'
            : 'Probe connection lost';
        trailing = TextButton(
          onPressed: () => ref.read(probeStatusProvider.notifier).connect(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Connect',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: border),
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
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Flexible(
                  child: Text(
                    statusText,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  /// Simulate Device Button control for mock hardware mode
  Widget _buildSimulateButton(ProbeConnectionStatus status) {
    final isConnected = status == ProbeConnectionStatus.connected;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44.0),
        backgroundColor: isConnected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceVariant.withValues(alpha: 0.3),
        foregroundColor: isConnected ? AppColors.primary : AppColors.secondaryText,
        side: BorderSide(
          color: isConnected
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      icon: const Icon(Icons.touch_app_rounded, size: 18.0),
      label: Text(
        'Simulate device button [Mock hardware]',
        style: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.w600,
          color: isConnected ? AppColors.primary : AppColors.secondaryText,
        ),
      ),
      onPressed: () async {
        try {
          await ref.read(pendingCapturesProvider.notifier).simulateDeviceButton();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notice: $e')),
            );
          }
        }
      },
    );
  }

  /// Toggle switcher between Mock Hardware and Physical ESP32-CAM probe
  Widget _buildModeSwitcher(bool isMockMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isMockMode ? Icons.science_outlined : Icons.wifi_rounded,
                size: 16.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                isMockMode ? 'Source: Mock Hardware' : 'Source: ESP32-CAM Wi-Fi',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              ref.read(isMockProbeProvider.notifier).toggle();
              ref.read(probeStatusProvider.notifier).connect();
            },
            borderRadius: BorderRadius.circular(AppRadii.small),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Text(
                isMockMode ? 'Switch to Real Probe' : 'Switch to Mock',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Real ESP32-CAM capture request button
  Widget _buildRealProbeControl(ProbeConnectionStatus status) {
    final isConnected = status == ProbeConnectionStatus.connected;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44.0),
        backgroundColor: isConnected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceVariant.withValues(alpha: 0.3),
        foregroundColor: isConnected ? AppColors.primary : AppColors.secondaryText,
        side: BorderSide(
          color: isConnected
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      icon: const Icon(Icons.download_rounded, size: 18.0),
      label: Text(
        'Request capture from probe [ESP32-CAM]',
        style: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.w600,
          color: isConnected ? AppColors.primary : AppColors.secondaryText,
        ),
      ),
      onPressed: isConnected
          ? () async {
              try {
                final probe = ref.read(probeServiceProvider);
                if (probe is HttpProbeService) {
                  final cap = await probe.fetchLatestCapture();
                  if (cap == null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new capture returned by ESP32 probe.')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Probe error: $e')),
                  );
                }
              }
            }
          : null,
    );
  }

  /// Empty state when no captures are waiting
  Widget _buildEmptyCapturesState(ProbeConnectionStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 28.0,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'No pending captures',
            style: AppTextStyles.title.copyWith(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Text(
            status == ProbeConnectionStatus.connected
                ? 'Press the physical probe button or click "Simulate device button" above.'
                : 'Connect the probe to receive sensor captures.',
            style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard({
    required BuildContext context,
    required Capture capture,
    required bool isNew,
    required VoidCallback onAnalyse,
    required VoidCallback onDelete,
  }) {
    final timestampStr =
        '${capture.receivedTime.day} ${_monthName(capture.receivedTime.month)} ${capture.receivedTime.year} • '
        '${capture.receivedTime.hour.toString().padLeft(2, '0')}:${capture.receivedTime.minute.toString().padLeft(2, '0')}';

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
                child: capture.imageBytes.isNotEmpty
                    ? Image.memory(
                        capture.imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.face_rounded,
                          size: 32.0,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
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
                            timestampStr,
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
                      'OV2640 Image • ${capture.formattedImageSize}',
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
                value: '${capture.sensorReading.moisture.toStringAsFixed(1)}%',
                bgColor: AppColors.sensorMoistureBg,
                iconColor: AppColors.sensorMoistureIcon,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorPill(
                icon: Icons.device_thermostat_rounded,
                label: 'Temperature',
                value: '${capture.sensorReading.temperature.toStringAsFixed(1)}°C',
                bgColor: AppColors.sensorTempBg,
                iconColor: AppColors.sensorTempIcon,
              ),
              const SizedBox(width: AppSpacing.s8),
              _buildSensorPill(
                icon: Icons.palette_outlined,
                label: 'Color Index',
                value: '${capture.sensorReading.colorIndex}',
                bgColor: AppColors.sensorColorBg,
                iconColor: AppColors.sensorColorIcon,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: AppSpacing.s12),

          // Action buttons: Eye Icon (Raw data) + Trash Icon (Delete) + Analyse Button
          Row(
            children: [
              // Eye Icon Button (View raw data)
              InkWell(
                onTap: () {
                  _showRawDataModal(
                    context: context,
                    capture: capture,
                    formattedTime: timestampStr,
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
                onTap: onDelete,
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
    required Capture capture,
    required String formattedTime,
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
              _buildRawDataRow('Capture ID', capture.id),
              _buildRawDataRow('Probe Camera', 'ESP32-CAM (OV2640)'),
              _buildRawDataRow('Resolution', '640 × 480 JPEG'),
              _buildRawDataRow('Payload Size', capture.formattedImageSize),
              _buildRawDataRow('Received At', formattedTime),
              _buildRawDataRow('Transfer Latency', '${capture.transferMs ?? 0} ms'),
              const Divider(height: 24.0, color: AppColors.border),
              _buildRawDataRow(
                'Moisture Sensor',
                '${capture.sensorReading.moisture.toStringAsFixed(1)}%',
              ),
              _buildRawDataRow(
                'Temperature',
                '${capture.sensorReading.temperature.toStringAsFixed(1)} °C',
              ),
              _buildRawDataRow(
                'Spectral Index',
                'Fitzpatrick Type ${capture.sensorReading.colorIndex}',
              ),
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

  Future<void> _confirmDelete(String captureId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        title: Text(
          'Delete capture?',
          style: AppTextStyles.title.copyWith(fontSize: 18.0),
        ),
        content: Text(
          'This will remove this unanalysed capture from memory. This action cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.label.copyWith(color: AppColors.secondaryText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(pendingCapturesProvider.notifier).removeCapture(captureId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture $captureId deleted'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
