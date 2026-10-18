import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/benchmark_state.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 4: Performance Dashboard (Member C's Core Research Showcase)
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);
    final benchmarkState = ref.watch(benchmarkStateProvider);
    final result = benchmarkState.result;

    final fp32 = result?.baselineFp32;
    final int8 = result?.quantizedInt8;

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
            Text('Performance', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            Text('Step 4 of 4', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s16),
            child: StepIndicator(currentStep: 4),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Original (float32) vs Compressed (int8)',
                style: AppTextStyles.title.copyWith(fontSize: 18.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4.0),
              Text(
                'On-device latency and size trade-off benchmark (Section 8 spec)',
                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Debug / Emulator warning banner per Skill guidelines
              if (kDebugMode) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20.0, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          'Debug mode active: timings include debug overhead and JIT compilation. '
                          'Run `flutter run --profile` on a physical device for publishable thesis results.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
              ],

              // Benchmark Error banner
              if (benchmarkState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 20.0, color: AppColors.error),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Benchmark Error',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              benchmarkState.error!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18.0, color: AppColors.secondaryText),
                        onPressed: () => ref.read(benchmarkStateProvider.notifier).reset(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
              ],

              // Run Benchmark Action Button
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
                onPressed: benchmarkState.isRunning
                    ? null
                    : () async {
                        final res = await ref
                            .read(benchmarkStateProvider.notifier)
                            .executeBenchmark(runs: 50, warmupRuns: 10);
                        if (res != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Benchmark completed! Speedup: ${res.speedupMultiplier?.toStringAsFixed(1)}x faster.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (benchmarkState.isRunning) ...[
                      const SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Running benchmark (${(benchmarkState.progress * 100).toInt()}%)...',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.play_arrow_rounded, size: 20.0),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        result == null ? 'Run benchmark' : 'Re-run benchmark (50 runs)',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Side-by-side comparison cards
              Row(
                children: [
                  // Float32 Card
                  Expanded(
                    child: _buildVariantCard(
                      title: 'Original (float32)',
                      size: fp32 != null ? '${fp32.sizeMb.toStringAsFixed(1)} MB' : '14.0 MB',
                      latency: fp32 != null ? '${fp32.latencyMs.mean.toStringAsFixed(1)} ms' : '— ms',
                      runs: result != null ? '${result.runs} runs' : 'Not run',
                      isCompressed: false,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  // INT8 Card
                  Expanded(
                    child: _buildVariantCard(
                      title: 'Compressed (int8)',
                      size: int8 != null ? '${int8.sizeMb.toStringAsFixed(1)} MB' : '4.0 MB',
                      latency: int8 != null ? '${int8.latencyMs.mean.toStringAsFixed(1)} ms' : '— ms',
                      runs: result != null ? '${result.runs} runs' : 'Not run',
                      isCompressed: true,
                      speedupBadge: result?.speedupMultiplier != null
                          ? '${result!.speedupMultiplier!.toStringAsFixed(1)}x faster'
                          : null,
                      sizeBadge: result?.sizeReductionPercent != null
                          ? '${result!.sizeReductionPercent!.toStringAsFixed(0)}% smaller'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Latency Comparison Card
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latency distribution (ms)',
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            _buildLegendItem('FP32', AppColors.chart1),
                            const SizedBox(width: AppSpacing.s12),
                            _buildLegendItem('INT8', AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarGroup(
                          'Min',
                          fp32?.latencyMs.min ?? 10.0,
                          int8?.latencyMs.min ?? 5.0,
                          maxVal: math.max(
                            fp32?.latencyMs.max ?? 30.0,
                            int8?.latencyMs.max ?? 20.0,
                          ),
                        ),
                        _buildBarGroup(
                          'Median',
                          fp32?.latencyMs.median ?? 18.0,
                          int8?.latencyMs.median ?? 8.0,
                          maxVal: math.max(
                            fp32?.latencyMs.max ?? 30.0,
                            int8?.latencyMs.max ?? 20.0,
                          ),
                        ),
                        _buildBarGroup(
                          'Mean',
                          fp32?.latencyMs.mean ?? 20.0,
                          int8?.latencyMs.mean ?? 9.0,
                          maxVal: math.max(
                            fp32?.latencyMs.max ?? 30.0,
                            int8?.latencyMs.max ?? 20.0,
                          ),
                        ),
                        _buildBarGroup(
                          'Max',
                          fp32?.latencyMs.max ?? 28.0,
                          int8?.latencyMs.max ?? 14.0,
                          maxVal: math.max(
                            fp32?.latencyMs.max ?? 30.0,
                            int8?.latencyMs.max ?? 20.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Model Metrics Comparison Table
              Text(
                'Model metrics',
                style: AppTextStyles.title.copyWith(fontSize: 16.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.s12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      'Size',
                      fp32 != null
                          ? '${fp32.sizeMb.toStringAsFixed(1)} MB / ${int8?.sizeMb.toStringAsFixed(1)} MB'
                          : '14.0 MB / 4.0 MB',
                      isHeader: true,
                    ),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow(
                      'Latency (mean)',
                      fp32 != null
                          ? '${fp32.latencyMs.mean.toStringAsFixed(1)} ms / ${int8?.latencyMs.mean.toStringAsFixed(1)} ms'
                          : '— / —',
                    ),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow(
                      'Latency (median)',
                      fp32 != null
                          ? '${fp32.latencyMs.median.toStringAsFixed(1)} ms / ${int8?.latencyMs.median.toStringAsFixed(1)} ms'
                          : '— / —',
                    ),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow(
                      'Latency (std dev)',
                      fp32 != null
                          ? '${fp32.latencyMs.std.toStringAsFixed(2)} ms / ${int8?.latencyMs.std.toStringAsFixed(2)} ms'
                          : '— / —',
                    ),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Accuracy (overall)', 'computed offline (test set)'),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Accuracy (rare classes)', 'computed offline (test set)'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Pipeline Timing Card
              Text(
                'Pipeline timing',
                style: AppTextStyles.title.copyWith(fontSize: 16.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPipelineItem(
                      'Transfer',
                      result?.pipelineMs.transferMean != null
                          ? '${result!.pipelineMs.transferMean!.toStringAsFixed(1)} ms'
                          : 'null (mock)',
                    ),
                    _buildPipelineItem(
                      'Preprocessing',
                      result != null
                          ? '${result.pipelineMs.preprocessMean.toStringAsFixed(1)} ms'
                          : '— ms',
                    ),
                    _buildPipelineItem(
                      'Total Pipeline',
                      result?.pipelineMs.totalMean != null
                          ? '${result!.pipelineMs.totalMean!.toStringAsFixed(1)} ms'
                          : '— ms',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // JSON Export Button (Section 8)
              if (result != null) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44.0),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                  ),
                  icon: const Icon(Icons.code_rounded, size: 18.0, color: AppColors.primary),
                  label: Text(
                    'View Section 8 Result JSON',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                  onPressed: () {
                    _showJsonModal(context, result);
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
              ],

              // Device Environment Tag
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    result != null
                        ? '${result.device} • Android ${result.androidVersion} • Placeholder model'
                        : 'Device: Android Phone • Placeholder model',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantCard({
    required String title,
    required String size,
    required String latency,
    required String runs,
    required bool isCompressed,
    String? speedupBadge,
    String? sizeBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isCompressed ? AppColors.primary : AppColors.border,
          width: isCompressed ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w700,
              color: isCompressed ? AppColors.primary : AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text('Model size', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 2.0),
          Text(size, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800, fontSize: 18.0)),
          const SizedBox(height: AppSpacing.s12),
          Text('Avg. latency', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 2.0),
          Text(
            latency,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18.0,
              color: isCompressed ? AppColors.primary : AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(runs, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          if (speedupBadge != null && sizeBadge != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    speedupBadge,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    sizeBadge,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarGroup(String label, double val1, double val2, {required double maxVal}) {
    final effectiveMax = maxVal <= 0 ? 1.0 : maxVal;
    final h1 = (val1 / effectiveMax * 70.0).clamp(6.0, 70.0);
    final h2 = (val2 / effectiveMax * 70.0).clamp(6.0, 70.0);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 16.0,
              height: h1,
              decoration: BoxDecoration(
                color: AppColors.chart1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3.0)),
              ),
            ),
            const SizedBox(width: 4.0),
            Container(
              width: 16.0,
              height: h2,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3.0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4.0),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 13.0,
              fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
              color: isHeader ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.0,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem(String label, String duration, {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isTotal ? AppColors.primary : AppColors.secondaryText,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          duration,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isTotal ? 16.0 : 14.0,
            color: isTotal ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }

  void _showJsonModal(BuildContext context, dynamic result) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(result.toJson());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadii.rExtraLarge),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: AppSpacing.screenPaddingAll,
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Section 8 Benchmark JSON', style: AppTextStyles.title),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
