/// Configuration constants for on-device TFLite model variants.
///
/// Modifying this file enables swapping between the stand-in model
/// and the final multimodal fusion model without changing UI or service code.
class ModelConfig {
  ModelConfig._();

  /// Asset path to baseline floating-point 32-bit model.
  static const String baselineFp32Path = 'assets/models/baseline_fp32.tflite';

  /// Asset path to quantized integer 8-bit model (post-training quantization).
  static const String quantizedInt8Path = 'assets/models/quantized_int8.tflite';

  /// Asset path to classification label mapping file.
  static const String labelsPath = 'assets/models/labels.txt';

  /// Input image tensor width in pixels.
  static const int inputWidth = 224;

  /// Input image tensor height in pixels.
  static const int inputHeight = 224;

  /// Input image tensor channel count (RGB).
  static const int inputChannels = 3;

  /// Image normalization mean (e.g. 127.5 for [-1, 1] range).
  static const double normMean = 127.5;

  /// Image normalization standard deviation.
  static const double normStd = 127.5;

  /// Default number of warm-up runs for latency benchmarking (not counted in stats).
  static const int defaultWarmupRuns = 10;

  /// Default number of timed benchmark runs.
  static const int defaultBenchmarkRuns = 50;

  /// Current model version tag.
  static const String modelVersion = 'standin_mobilenet_v2';

  /// Display disclaimer text for stand-in model outputs.
  static const String placeholderModelNotice =
      'Placeholder model — stand-in model used for latency and deployment benchmarking.';
}

