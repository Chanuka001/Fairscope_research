import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 4: Performance Dashboard (Member C's Core Research Feature)
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => navController.handleBack(),
        ),
        title: Column(
          children: [
            Text('Performance', style: AppTextStyles.title),
            Text('Step 4 of 4', style: AppTextStyles.caption),
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
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original (float32) vs Compressed (int8)',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'On-device latency and size trade-off benchmark',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Run Benchmark Action Button
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Benchmark service will run in Task 10.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run benchmark'),
              ),
              const SizedBox(height: AppSpacing.s24),

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
                      speedupBadge: '5.4x faster',
                      sizeBadge: '4.0x smaller',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),

              // Metrics Comparison Table Placeholder
              Text('Model metrics', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.s12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  children: [
                    _buildMetricRow('Size', '98.4 MB', '24.6 MB', isHeader: true),
                    const Divider(),
                    _buildMetricRow('Latency (mean)', '842 ms', '156 ms'),
                    const Divider(),
                    _buildMetricRow('Latency (median)', '801 ms', '142 ms'),
                    const Divider(),
                    _buildMetricRow('Latency (std dev)', '120 ms', '38 ms'),
                    const Divider(),
                    _buildMetricRow('Accuracy (overall)', 'not measured yet', 'not measured yet'),
                    const Divider(),
                    _buildMetricRow('Accuracy (rare classes)', 'not measured yet', 'not measured yet'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Pipeline Timing Card
              Text('Pipeline timing', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: AppSpacing.cardPaddingAll,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.brLarge,
                  border: Border.all(color: AppColors.border),
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

              const SizedBox(height: AppSpacing.s24),

              // Device environment chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadii.brMedium,
                  ),
                  child: Text(
                    'Device: Android Device • Sample benchmark data',
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
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLarge,
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
          Text('Model size', style: AppTextStyles.caption),
          Text(size, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.s12),
          Text('Avg. latency', style: AppTextStyles.caption),
          Text(
            latency,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w700,
              color: isCompressed ? AppColors.success : AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(runs, style: AppTextStyles.caption),
          if (speedupBadge != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadii.brSmall,
              ),
              child: Text(
                '⚡ $speedupBadge',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String metric,
    String fp32Val,
    String int8Val, {
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              metric,
              style: isHeader
                  ? AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)
                  : AppTextStyles.body.copyWith(fontSize: 14.0),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fp32Val,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              int8Val,
              textAlign: TextAlign.right,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
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
            fontWeight: FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.text,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

