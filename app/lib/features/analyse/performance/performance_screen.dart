import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original (float32) vs Compressed (int8)',
                style: AppTextStyles.title.copyWith(fontSize: 18.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4.0),
              Text(
                'On-device latency and size trade-off benchmark',
                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Run Benchmark Button
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Benchmark service execution will be implemented in Task 10.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 20.0),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Run benchmark',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: AppColors.onPrimary,
                      ),
                    ),
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
                      size: '98.4 MB',
                      latency: '842 ms',
                      runs: '100 runs',
                      isCompressed: false,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  // INT8 Card
                  Expanded(
                    child: _buildVariantCard(
                      title: 'Compressed (int8)',
                      size: '24.6 MB',
                      latency: '156 ms',
                      runs: '100 runs',
                      isCompressed: true,
                      speedupBadge: 'x5.4 faster',
                      sizeBadge: 'x4.0 smaller',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Latency Bar Chart (P50, P90, P99)
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
                          'Latency (ms)',
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            _buildLegendItem('Original', AppColors.chart1),
                            const SizedBox(width: AppSpacing.s12),
                            _buildLegendItem('Compressed', AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarGroup('P50', 801, 142, maxVal: 1200),
                        _buildBarGroup('P90', 920, 180, maxVal: 1200),
                        _buildBarGroup('P99', 1150, 240, maxVal: 1200),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Metrics Comparison Table
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
                    _buildMetricRow('Size', '98.4 MB / 24.6 MB', isHeader: true),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Latency (mean)', '842 ms / 156 ms'),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Latency (median)', '801 ms / 142 ms'),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Latency (std dev)', '120 ms / 38 ms'),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Accuracy (overall)', 'not measured yet'),
                    const Divider(height: 1.0, color: AppColors.border),
                    _buildMetricRow('Accuracy (rare classes)', 'not measured yet'),
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
                    _buildPipelineItem('Transfer', '120 ms'),
                    _buildPipelineItem('Preprocessing', '420 ms'),
                    _buildPipelineItem('Total', '540 ms', isTotal: true),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // Device Environment Tag
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    'Device: Pixel 7 • Android 14 • Placeholder model',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
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
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                  ),
                  child: Text(
                    speedupBadge,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                  ),
                  child: Text(
                    sizeBadge,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4.0),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11.0)),
      ],
    );
  }

  Widget _buildBarGroup(String label, double origVal, double compVal, {required double maxVal}) {
    const maxHeight = 100.0;
    final origHeight = (origVal / maxVal) * maxHeight;
    final compHeight = (compVal / maxVal) * maxHeight;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 16.0,
              height: origHeight,
              decoration: BoxDecoration(
                color: AppColors.chart1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3.0)),
              ),
            ),
            const SizedBox(width: 4.0),
            Container(
              width: 16.0,
              height: compHeight,
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

  Widget _buildMetricRow(String metric, String val, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: isHeader
                ? AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)
                : AppTextStyles.body.copyWith(fontSize: 14.0),
          ),
          Text(
            val,
            style: isHeader
                ? AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)
                : AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem(String label, String time, {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          time,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
            color: isTotal ? AppColors.primary : AppColors.text,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? AppColors.primary : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
