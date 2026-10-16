import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Grouped bar chart comparing Image-Only vs Multimodal (Image + Sensor)
/// across Fitzpatrick Skin Types I through VI matching Explane5.png.
class FairnessBarChart extends StatelessWidget {
  const FairnessBarChart({super.key});

  static const List<_FitzpatrickData> _data = [
    _FitzpatrickData(type: 'I', imageOnly: 0.58, multimodal: 0.68),
    _FitzpatrickData(type: 'II', imageOnly: 0.74, multimodal: 0.84),
    _FitzpatrickData(type: 'III', imageOnly: 0.67, multimodal: 0.77),
    _FitzpatrickData(type: 'IV', imageOnly: 0.67, multimodal: 0.77),
    _FitzpatrickData(type: 'V', imageOnly: 0.66, multimodal: 0.75),
    _FitzpatrickData(type: 'VI', imageOnly: 0.58, multimodal: 0.67),
  ];

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 150.0;
    final yLabels = ['100%', '75%', '50%', '25%', '0%'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Chart Legend matching Explane5.png
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(color: AppColors.chartSeries1, label: 'Image only'),
            const SizedBox(width: 20),
            _buildLegendItem(color: AppColors.chartSeries2, label: 'Image + sensor'),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Bar Chart with Y-Axis and Horizontal Grid Lines
        SizedBox(
          height: chartHeight,
          child: Stack(
            children: [
              // Grid lines
              Positioned.fill(
                left: 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return Container(
                      height: 1,
                      color: const Color(0xFFE2E8F0),
                    );
                  }),
                ),
              ),
              // Y-Axis Labels
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 36,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels.map((label) {
                    return Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Grouped Bars
              Positioned(
                left: 48,
                right: 12,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _data.map((item) {
                    return _buildBarGroup(item, chartHeight);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 3. X-Axis Labels (Fitzpatrick Types I to VI)
        Padding(
          padding: const EdgeInsets.only(left: 48, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _data.map((item) {
              return SizedBox(
                width: 34,
                child: Text(
                  item.type,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBarGroup(_FitzpatrickData item, double maxHeight) {
    const double barWidth = 11.0;
    final double imageOnlyHeight = item.imageOnly * maxHeight;
    final double multimodalHeight = item.multimodal * maxHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Image Only Bar
        Container(
          width: barWidth,
          height: imageOnlyHeight,
          decoration: const BoxDecoration(
            color: AppColors.chartSeries1, // #38BDF8 Sky Blue
            borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
        const SizedBox(width: 3),
        // Multimodal Bar
        Container(
          width: barWidth,
          height: multimodalHeight,
          decoration: const BoxDecoration(
            color: AppColors.chartSeries2, // #0F766E Teal
            borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
      ],
    );
  }
}

class _FitzpatrickData {
  final String type;
  final double imageOnly;
  final double multimodal;

  const _FitzpatrickData({
    required this.type,
    required this.imageOnly,
    required this.multimodal,
  });
}
