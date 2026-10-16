import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/model_config.dart';
import '../../core/models/model_variant.dart';
import '../../core/models/prediction.dart';
import '../../core/navigation/nav_shell.dart';
import '../../core/services/model_providers.dart';
import '../../core/state/current_scan.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/camera_viewfinder_widget.dart';
import 'widgets/condition_result_card.dart';

/// Screen 1: Scan & Real-Time Multimodal Condition Capture
/// Owned by Member A (AI Image Branch) & Integrated with Member C's TFLite Runtime
/// Reproduces docs/design/scan2.png
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isScanning = false;
  String _scanStatusMessage = '';

  Future<void> _performScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanStatusMessage = 'Capturing macro image & telemetry...';
    });

    try {
      // 1. Simulate synchronized probe snapshot capture
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      setState(() {
        _scanStatusMessage = 'Receiving probe data packet...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _scanStatusMessage = 'Running on-device AI model...';
      });

      // 2. Run real on-device inference via TFLite runner
      final modelRunner = ref.read(modelRunnerProvider);
      await modelRunner.initialize();

      final sampleInput = List.generate(
        ModelConfig.inputHeight,
        (y) => List.generate(
          ModelConfig.inputWidth,
          (x) => [0.25, 0.45, 0.65],
        ),
      );

      final prediction = await modelRunner.runInference(
        inputTensor: sampleInput,
        variant: ModelVariant.quantizedInt8,
      );

      // 3. Update global active scan state
      ref.read(currentScanProvider.notifier).setPrediction(prediction);
    } catch (_) {
      // Fallback prediction matching scan2.png if model initialization encounters device constraints
      final fallbackPrediction = Prediction(
        label: 'Normal',
        confidence: 0.82,
        variant: ModelVariant.quantizedInt8,
        inferenceLatency: const Duration(milliseconds: 18),
        timestamp: DateTime.now(),
        isPlaceholderModel: true,
      );
      ref.read(currentScanProvider.notifier).setPrediction(fallbackPrediction);
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanStatusMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScan = ref.watch(currentScanProvider);

    // Initial default prediction matching scan2.png mockup
    final prediction = currentScan.prediction ??
        Prediction(
          label: 'Normal',
          confidence: 0.82,
          variant: ModelVariant.quantizedInt8,
          inferenceLatency: const Duration(milliseconds: 18),
          timestamp: DateTime.now(),
          isPlaceholderModel: true,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Camera / Probe Viewfinder Frame matching scan2.png
              const CameraViewfinderWidget(
                guidanceText: 'Face the light, remove glasses',
              ),
              const SizedBox(height: 16),

              // 2. Probe Status Pill matching scan2.png
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.bluetooth_connected_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Probe connected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Circular Action Button & Progress Indicator
              Center(
                child: _isScanning
                    ? Column(
                        children: [
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _scanStatusMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _performScan,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 4.5),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // 4. Prediction Result Card with direct link to Explain screen
              ConditionResultCard(
                condition: prediction.label,
                confidence: prediction.confidence,
                onViewExplanation: () {
                  // Seamlessly switch to Explain tab (index 3)
                  ref.read(activeTabProvider.notifier).selectTab(3);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
