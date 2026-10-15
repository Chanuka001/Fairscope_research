/// Central configuration defining model contracts, file assets, and dimensions.
/// Owned by Member C. Allows swapping stand-in models for real fusion models via config.
class ModelConfig {
  ModelConfig._();

  // Model Asset Paths
  static const String baselineFp32Asset = 'assets/models/baseline_fp32.tflite';
  static const String quantizedInt8Asset = 'assets/models/quantized_int8.tflite';
  static const String labelsAsset = 'assets/models/labels.txt';

  // Input Dimensions (Stand-in MobileNet standard)
  static const int inputWidth = 224;
  static const int inputHeight = 224;
  static const int inputChannels = 3;

  // Normalization parameters
  // MobileNet standard: pixel values scaled to [-1.0, 1.0] or [0.0, 1.0]
  static const double normMean = 127.5;
  static const double normStd = 127.5;

  // Benchmark defaults per Section 6
  static const int defaultBenchmarkRuns = 50;
  static const int defaultWarmupRuns = 10;
  static const String currentModelVersion = 'standin_mobilenet_v1';
}
