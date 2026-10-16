import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Clean custom Latency Comparison bar chart matching compare4.png design.
class LatencyBarChart extends StatelessWidget {
  final double originalMs;
  final double compressedMs;

  const LatencyBarChart({
    super.key,
    required this.originalMs,
    required this.compressedMs,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic max for y-axis with 4 intervals (e.g. 0, 20, 40, 60)
    final peakVal = max(originalMs, compressedMs);
    final ceilMax = ((peakVal * 1.3) / 20).ceil() * 20.0;
    final yMax = ceilMax < 40 ? 40.0 : ceilMax;
    final intervals = [yMax, yMax * 0.66, yMax * 0.33, 0.0];

    const double chartHeight = 160.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: chartHeight,
            child: Stack(
              children: [
                // 1. Grid Lines and Y-Axis Labels
                Positioned.fill(
                  left: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: intervals.map((val) {
                      return Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 2. Bars
                Positioned(
                  left: 45,
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Original bar
                      _buildBar(
                        value: originalMs,
                        yMax: yMax,
                        chartHeight: chartHeight,
                        barColor: AppColors.chartSeries1, // #38BDF8
                      ),
                      // Compressed bar
                      _buildBar(
                        value: compressedMs,
                        yMax: yMax,
                        chartHeight: chartHeight,
                        barColor: AppColors.chartSeries2, // #0F766E
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 3. X-Axis Labels
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Expanded(
                  child: Text(
                    'Original (float32)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Compressed (int8)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required double value,
    required double yMax,
    required double chartHeight,
    required Color barColor,
  }) {
    // Leave 26px for label on top of bar
    final availableHeight = chartHeight - 26;
    final barHeight = (value / yMax) * availableHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${value.round()} ms',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: barHeight),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, animatedHeight, child) {
            return Container(
              width: 72,
              height: animatedHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

