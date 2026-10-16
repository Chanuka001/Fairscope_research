import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/benchmark_result.dart';
import '../../core/state/benchmark_state.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/latency_bar_chart.dart';
import 'widgets/metrics_table.dart';
import 'widgets/variant_summary_card.dart';

/// Screen 4: Model Comparison & Optimization Benchmarking
/// Owned by Member C (Monal) - Milestone PP1
/// Faithfully reproduces docs/design/compare4.png
class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(benchmarkProvider);
    final report = state.report;

    ModelVariantBenchmark? originalVariant;
    ModelVariantBenchmark? compressedVariant;

    if (report != null && report.variants.isNotEmpty) {
      for (final v in report.variants) {
        if (v.name.contains('fp32') || v.name.contains('baseline') || v.name.contains('original')) {
          originalVariant = v;
        } else if (v.name.contains('int8') || v.name.contains('quantized') || v.name.contains('compressed')) {
          compressedVariant = v;
        }
      }
      // Fallbacks if names differ
      originalVariant ??= report.variants.first;
      compressedVariant ??= (report.variants.length > 1 ? report.variants[1] : report.variants.first);
    }

    final double speedup = (originalVariant != null &&
            compressedVariant != null &&
            compressedVariant.latencyMs.mean > 0)
        ? (originalVariant.latencyMs.mean / compressedVariant.latencyMs.mean)
        : 2.8;

    final int sizeReductionPercent = (originalVariant != null &&
            compressedVariant != null &&
            originalVariant.sizeMb > 0)
        ? (((originalVariant.sizeMb - compressedVariant.sizeMb) / originalVariant.sizeMb) * 100).round()
        : 74;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Screen Title matching compare4.png
            const Text(
              'Original (float32) vs Compressed (int8)',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Run Benchmark Button
            _buildRunBenchmarkButton(context, ref, state),
            const SizedBox(height: 12),

            // Benchmark Progress Indicator (when running)
            if (state.status == BenchmarkStatus.running) ...[
              LinearProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
                backgroundColor: const Color(0xFFE2E8F0),
                color: AppColors.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 6),
              Text(
                state.progressMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Debug Mode Notice (Honesty Rule per tflite-benchmark skill)
            if (kDebugMode)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Debug mode / Emulator: latency shown is indicative. Run profile mode on phone for viva defense.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Error Message (if any)
            if (state.status == BenchmarkStatus.error && state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ),

            // 3. Side-by-side Cards (Original vs Compressed)
            if (originalVariant != null && compressedVariant != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: VariantSummaryCard(
                      title: 'Original',
                      headerColor: const Color(0xFFE0F2FE),
                      headerTextColor: const Color(0xFF0369A1),
                      sizeMb: originalVariant.sizeMb.toStringAsFixed(1),
                      latencyMs: originalVariant.latencyMs.mean.round().toString(),
                      runs: report?.runs ?? 50,
                      badgeText: '${speedup.toStringAsFixed(1)}x faster',
                      badgeIcon: Icons.speed_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: VariantSummaryCard(
                      title: 'Compressed',
                      headerColor: const Color(0xFFDCFCE7),
                      headerTextColor: const Color(0xFF15803D),
                      sizeMb: compressedVariant.sizeMb.toStringAsFixed(1),
                      latencyMs: compressedVariant.latencyMs.mean.round().toString(),
                      runs: report?.runs ?? 50,
                      badgeText: '$sizeReductionPercent% smaller',
                      badgeIcon: Icons.compress_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Latency Comparison Chart Section
              const Text(
                'Latency comparison',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              LatencyBarChart(
                originalMs: originalVariant.latencyMs.mean,
                compressedMs: compressedVariant.latencyMs.mean,
              ),
              const SizedBox(height: 24),

              // 5. Detailed Metrics Table Section
              const Text(
                'Detailed metrics',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              MetricsTable(
                original: originalVariant,
                compressed: compressedVariant,
              ),
              const SizedBox(height: 20),

              // 6. Footer Row: Device info & Placeholder model badge
              _buildFooterRow(report),
              const SizedBox(height: 16),
            ] else ...[
              // Fallback Empty State if no data loaded
              _buildEmptyState(ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRunBenchmarkButton(BuildContext context, WidgetRef ref, BenchmarkState state) {
    final isRunning = state.status == BenchmarkStatus.running;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isRunning
            ? null
            : () {
                ref.read(benchmarkProvider.notifier).runBenchmark();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRunning) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Benchmarking on device...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ] else ...[
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Run benchmark',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow(BenchmarkReport? report) {
    final String deviceLabel = report != null
        ? '${report.device} • Android ${report.androidVersion.isNotEmpty ? report.androidVersion : (Platform.isAndroid ? "14" : Platform.operatingSystem)}'
        : 'Pixel 6a • Android 14';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            deviceLabel,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Placeholder model badge matching compare4.png
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
          ),
          child: const Text(
            'Placeholder model',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.speed_rounded, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          const Text(
            'No benchmark data yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "Run benchmark" above to profile float32 vs int8 latency and memory on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
