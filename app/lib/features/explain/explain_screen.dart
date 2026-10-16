import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/current_scan.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/fairness_bar_chart.dart';
import 'widgets/heatmap_visualizer_widget.dart';

/// Screen 4: Explainability, Saliency Heatmaps & Demographic Fairness
/// Owned by Member D: AI Explainability & Cross-Population Fairness
/// Reproduces docs/design/Explane5.png
class ExplainScreen extends ConsumerStatefulWidget {
  const ExplainScreen({super.key});

  @override
  ConsumerState<ExplainScreen> createState() => _ExplainScreenState();
}

class _ExplainScreenState extends ConsumerState<ExplainScreen> {
  double _opacity = 0.70;

  @override
  Widget build(BuildContext context) {
    final currentScan = ref.watch(currentScanProvider);
    final reading = currentScan.sensorReading;

    // Dynamic moisture insight connecting sensor data with visual attention
    final String moistureText = (reading != null && reading.moisturePercent < 45)
        ? 'Skin moisture was below average (${reading.moisturePercent.toStringAsFixed(0)}%).'
        : 'Skin moisture was below average.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Title matching Explane5.png
              const Text(
                'Model attention (Grad-CAM)',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Heatmap Visualizer with Opacity Slider matching Explane5.png
              HeatmapVisualizerWidget(
                opacity: _opacity,
                onOpacityChanged: (val) {
                  setState(() => _opacity = val);
                },
              ),
              const SizedBox(height: 16),

              // 3. Multimodal Attention Insight Card matching Explane5.png
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft clinical blue card
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'The model focused on the highlighted cheek area.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moistureText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Accuracy by Skin Tone Container matching Explane5.png
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header container banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Accuracy by skin tone (Fitzpatrick I to VI)',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Fairness grouped bar chart
                    const FairnessBarChart(),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Bottom Footer Pill: Sample Data Badge matching Explane5.png
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                    ),
                    child: const Text(
                      'Sample data',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
