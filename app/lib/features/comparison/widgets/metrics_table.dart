import 'package:flutter/material.dart';
import '../../../core/models/benchmark_result.dart';
import '../../../core/theme/app_colors.dart';

/// Detailed metrics comparison table matching compare4.png design.
class MetricsTable extends StatelessWidget {
  final ModelVariantBenchmark original;
  final ModelVariantBenchmark compressed;

  const MetricsTable({
    super.key,
    required this.original,
    required this.compressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Row
          Container(
            color: const Color(0xFFEFF6FF), // Soft light blue header
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Metric',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Original',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Compressed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Rows
          _buildRow('Size', '${original.sizeMb} MB', '${compressed.sizeMb} MB'),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          _buildRow(
            'Latency (mean)',
            '${original.latencyMs.mean.round()} ms',
            '${compressed.latencyMs.mean.round()} ms',
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          _buildRow(
            'Latency (median)',
            '${original.latencyMs.median.round()} ms',
            '${compressed.latencyMs.median.round()} ms',
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          _buildRow(
            'Std deviation',
            '${original.latencyMs.std.round()} ms',
            '${compressed.latencyMs.std.round()} ms',
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          _buildRow(
            'Accuracy (overall)',
            original.accuracyOverall != null ? '${original.accuracyOverall}%' : 'not measured yet',
            compressed.accuracyOverall != null ? '${compressed.accuracyOverall}%' : 'not measured yet',
            isMuted: original.accuracyOverall == null,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          _buildRow(
            'Accuracy (rare classes)',
            original.accuracyRare != null ? '${original.accuracyRare}%' : 'not measured yet',
            compressed.accuracyRare != null ? '${compressed.accuracyRare}%' : 'not measured yet',
            isMuted: original.accuracyRare == null,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String metric,
    String originalVal,
    String compressedVal, {
    bool isMuted = false,
  }) {
    final valueStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: isMuted ? FontWeight.w400 : FontWeight.w600,
      fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
      color: isMuted ? const Color(0xFF64748B) : AppColors.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              metric,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              originalVal,
              style: valueStyle,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              compressedVal,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

