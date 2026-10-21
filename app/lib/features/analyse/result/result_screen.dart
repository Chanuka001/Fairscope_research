import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/scan_record.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/history_state.dart';
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
    Future.microtask(() async {
      final capture = ref.read(selectedCaptureProvider);
      final currentPrediction = ref.read(analysisProvider).prediction;
      final currentId = ref.read(currentScanIdProvider);

      if (capture != null && currentId == null) {
        if (currentPrediction == null) {
          final pred = await ref.read(analysisProvider.notifier).analyseCapture(capture);
          if (pred != null && mounted) {
            await _checkAndAutoSave();
          }
        } else {
          await _checkAndAutoSave();
        }
      }
    });
  }

  Future<void> _checkAndAutoSave() async {
    final capture = ref.read(selectedCaptureProvider);
    final analysis = ref.read(analysisProvider);
    final currentId = ref.read(currentScanIdProvider);

    if (capture != null && analysis.prediction != null && currentId == null) {
      await ref.read(historyProvider.notifier).saveAnalysedScan(
            capture: capture,
            prediction: analysis.prediction!,
            preprocessMs: analysis.preprocessMs,
            inferenceMs: analysis.inferenceMs,
            modelVariant: ref.read(activeModelVariantProvider),
          );
    }
  }

  void _showEditLabelDialog(String scanId, String? currentLabel) {
    final controller = TextEditingController(text: currentLabel ?? '');

    showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        title: Text(
          'Label $scanId',
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16.0, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Do not enter real names or personal details.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Scan Label (Optional)',
                hintText: 'e.g. Forehead Scan #1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(null),
            child: Text(
              'Cancel',
              style: AppTextStyles.label.copyWith(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((newLabel) {
      if (newLabel != null && mounted) {
        ref.read(historyProvider.notifier).updateLabel(scanId, newLabel);
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
            Text('Step 2 of 3', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s16),
            child: StepIndicator(currentStep: 2, totalSteps: 3),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Face Region Photo Card (1:1 Square)
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        width: double.infinity,
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
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.face_rounded,
                                  size: 72.0,
                                  color: AppColors.primary,
                                ),
                              )
                            : Image.asset(
                                'assets/images/avatas/result-screen img.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Image.asset(
                                  'assets/images/avatas/user_avatar_type_II.png',
                                  fit: BoxFit.cover,
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

              // Auto ID and Optional Label Pill
              Consumer(
                builder: (context, ref, _) {
                  final scanId = ref.watch(currentScanIdProvider);
                  final allRecords = ref.watch(filteredHistoryRecordsProvider);
                  final currentRecord = allRecords.cast<ScanRecord?>().firstWhere(
                    (r) => r?.id == scanId,
                    orElse: () => null,
                  );

                  if (scanId == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: Material(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        onTap: () => _showEditLabelDialog(scanId, currentRecord?.label),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 16.0, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.s8),
                              Text(
                                scanId,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (currentRecord?.label != null && currentRecord!.label!.isNotEmpty) ...[
                                const SizedBox(width: AppSpacing.s6),
                                Text(
                                  '•  ${currentRecord.label}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: AppSpacing.s6),
                                Text(
                                  '(Add label)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(width: AppSpacing.s8),
                              const Icon(Icons.edit_note_rounded, size: 16.0, color: AppColors.secondaryText),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

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
                    : analysis.error != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36.0),
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  'Inference Error',
                                  style: AppTextStyles.title.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  analysis.error!,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (selectedCapture != null) {
                                      final pred = await ref.read(analysisProvider.notifier).analyseCapture(selectedCapture);
                                      if (pred != null && mounted) {
                                        await _checkAndAutoSave();
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18.0),
                                  label: const Text('Retry Analysis'),
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
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        ),
      ),

      // Fixed Bottom Action Bar (Transparent)
      Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.s8,
          AppSpacing.screenPadding,
          AppSpacing.s16,
        ),
        child: FilledButton(
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
      ),
    ],
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
