import 'dart:typed_data';

/// Preprocessing pipeline configuration options.
class PreprocessOptions {
  final int targetWidth;
  final int targetHeight;
  final bool isQuantized;
  final double mean;
  final double std;

  const PreprocessOptions({
    this.targetWidth = 224,
    this.targetHeight = 224,
    this.isQuantized = false,
    this.mean = 127.5,
    this.std = 127.5,
  });
}

/// Abstract image preprocessor for probe OV2640 JPEG images.
///
/// Converts raw compressed JPEG bytes into 4D tensor buffers
/// [1, height, width, 3] matching the TFLite model specifications.
abstract class ImagePreprocessor {
  /// Preprocesses raw JPEG bytes into model-ready tensor inputs.
  /// Runs off the main UI thread via background worker/isolate.
  Future<dynamic> preprocess(
    Uint8List jpegBytes, {
    PreprocessOptions options = const PreprocessOptions(),
  });

  /// Timing duration in milliseconds for the most recent preprocessing run.
  double? get lastPreprocessDurationMs;
}

