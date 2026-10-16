import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Face illustration with interactive Grad-CAM heatmap overlay matching Explane5.png.
class HeatmapVisualizerWidget extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onOpacityChanged;

  const HeatmapVisualizerWidget({
    super.key,
    required this.opacity,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Face Illustration + Vertical Color Bar
        SizedBox(
          height: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 36), // Balance the color bar on right

              // Center Face Illustration with Saliency Heatmap Overlay
              SizedBox(
                width: 200,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base Face & Neck
                    _buildBaseFace(),

                    // Grad-CAM Attention Heatmap Overlay (Opacity controlled by slider)
                    Opacity(
                      opacity: opacity,
                      child: _buildHeatmapOverlay(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Vertical High -> Low Spectrum Bar matching Explane5.png
              _buildSpectrumBar(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Interactive Opacity Slider matching Explane5.png
        Row(
          children: [
            const Text(
              'Opacity',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.15),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: opacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onOpacityChanged,
                ),
              ),
            ),
            Text(
              '${(opacity * 100).round()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBaseFace() {
    return Container(
      width: 165,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF93C5FD).withValues(alpha: 0.25), // Soft clinical blue tint
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hair
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
              ),
            ),
          ),
          // Eyebrows
          Positioned(
            top: 85,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 22, height: 3, decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(2))),
                Container(width: 22, height: 3, decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          // Eyes
          Positioned(
            top: 98,
            left: 42,
            right: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 10, height: 7, decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle)),
                Container(width: 10, height: 7, decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle)),
              ],
            ),
          ),
          // Nose line
          Positioned(
            top: 115,
            child: Container(
              width: 2,
              height: 24,
              color: const Color(0xFF2563EB).withValues(alpha: 0.5),
            ),
          ),
          // Mouth
          Positioned(
            bottom: 45,
            child: Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapOverlay() {
    return Stack(
      children: [
        // Forehead heat patch
        Positioned(
          top: 35,
          right: 35,
          child: Container(
            width: 58,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.9), // Core red
                  const Color(0xFFF59E0B).withValues(alpha: 0.8), // Orange
                  const Color(0xFFFDE047).withValues(alpha: 0.5), // Yellow
                  Colors.transparent,
                ],
                stops: const [0.2, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),
        // Cheek heat patch (Primary attention area)
        Positioned(
          top: 85,
          right: 30,
          child: Container(
            width: 78,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFDC2626).withValues(alpha: 0.95), // Deep red focus
                  const Color(0xFFF97316).withValues(alpha: 0.85), // Vivid orange
                  const Color(0xFFFBBF24).withValues(alpha: 0.6),  // Amber
                  Colors.transparent,
                ],
                stops: const [0.25, 0.55, 0.82, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpectrumBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'High',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 14,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFDC2626), // Red
                Color(0xFFF97316), // Orange
                Color(0xFFFBBF24), // Yellow
                Color(0xFF38BDF8), // Blue
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Low',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
