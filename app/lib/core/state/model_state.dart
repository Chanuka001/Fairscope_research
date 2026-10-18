import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';
import '../models/prediction.dart';
import '../services/image_preprocessor.dart';
import '../services/isolate_image_preprocessor.dart';
import '../services/model_runner_service.dart';
import '../services/tflite_model_runner_service.dart';

/// Provider for the background image preprocessor.
final imagePreprocessorProvider = Provider<ImagePreprocessor>((ref) {
  return IsolateImagePreprocessor();
});

/// Provider for the singleton on-device TFLite model runner.
final modelRunnerProvider = Provider<ModelRunnerService>((ref) {
  final runner = TfliteModelRunnerService();
  ref.onDispose(() => runner.dispose());
  return runner;
});

/// Active model variant: 'baseline_fp32' or 'quantized_int8'.
class ActiveModelVariantNotifier extends Notifier<String> {
  @override
  String build() => 'baseline_fp32';

  void setVariant(String variant) {
    if (variant == 'baseline_fp32' || variant == 'quantized_int8') {
      state = variant;
    }
  }

  void toggle() {
    state = state == 'baseline_fp32' ? 'quantized_int8' : 'baseline_fp32';
  }
}

final activeModelVariantProvider =
    NotifierProvider<ActiveModelVariantNotifier, String>(
  ActiveModelVariantNotifier.new,
);

/// State of an active analysis run on Step 2.
class AnalysisState {
  final bool isLoading;
  final Prediction? prediction;
  final String? error;
  final double? preprocessMs;
  final double? inferenceMs;

  const AnalysisState({
    this.isLoading = false,
    this.prediction,
    this.error,
    this.preprocessMs,
    this.inferenceMs,
  });

  AnalysisState copyWith({
    bool? isLoading,
    Prediction? prediction,
    String? error,
    double? preprocessMs,
    double? inferenceMs,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      prediction: prediction ?? this.prediction,
      error: error,
      preprocessMs: preprocessMs ?? this.preprocessMs,
      inferenceMs: inferenceMs ?? this.inferenceMs,
    );
  }
}

class AnalysisNotifier extends Notifier<AnalysisState> {
  @override
  AnalysisState build() => const AnalysisState();

  Future<Prediction?> analyseCapture(Capture capture, {String? variant}) async {
    final String activeVariant = variant ?? ref.read(activeModelVariantProvider);
    final preprocessor = ref.read(imagePreprocessorProvider);
    final runner = ref.read(modelRunnerProvider);

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Image preprocessing off UI thread (isolate)
      developer.log('Preprocessing image for inference...', name: 'AnalysisNotifier');
      final inputTensor = await preprocessor.preprocess(
        capture.imageBytes,
        options: PreprocessOptions(
          isQuantized: activeVariant == 'quantized_int8',
        ),
      );
      final preprocessMs = preprocessor.lastPreprocessDurationMs;

      // 2. Load model variant if not already loaded
      await runner.loadModel(activeVariant);

      // 3. Isolated inference call
      final sw = Stopwatch()..start();
      final prediction = await runner.runInference(inputTensor);
      sw.stop();
      final inferenceMs = sw.elapsedMicroseconds / 1000.0;

      state = AnalysisState(
        isLoading: false,
        prediction: prediction,
        preprocessMs: preprocessMs,
        inferenceMs: inferenceMs,
      );

      return prediction;
    } catch (e, st) {
      developer.log('Analysis error: $e', name: 'AnalysisNotifier', error: e, stackTrace: st);
      state = AnalysisState(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const AnalysisState();
  }
}

final analysisProvider =
    NotifierProvider<AnalysisNotifier, AnalysisState>(AnalysisNotifier.new);

