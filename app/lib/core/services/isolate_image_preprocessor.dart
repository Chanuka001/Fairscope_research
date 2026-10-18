import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'image_preprocessor.dart';

class _PreprocessPayload {
  final Uint8List jpegBytes;
  final int targetWidth;
  final int targetHeight;
  final bool isQuantized;
  final double mean;
  final double std;

  _PreprocessPayload({
    required this.jpegBytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.isQuantized,
    required this.mean,
    required this.std,
  });
}

/// Preprocessing isolate worker function executed off the main UI thread.
dynamic _preprocessIsolate(_PreprocessPayload payload) {
  img.Image? decoded = img.decodeImage(payload.jpegBytes);
  decoded ??= img.Image(width: payload.targetWidth, height: payload.targetHeight);

  // Crop square from center then resize to target dimensions
  final resized = img.copyResizeCropSquare(
    decoded,
    size: payload.targetWidth,
  );

  final width = payload.targetWidth;
  final height = payload.targetHeight;

  if (payload.isQuantized) {
    // Quantized INT8 tensor buffer: shape [height, width, 3], range [-128, 127]
    return List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          final p = resized.getPixel(x, y);
          final r = (p.r - 128).clamp(-128, 127).toInt();
          final g = (p.g - 128).clamp(-128, 127).toInt();
          final b = (p.b - 128).clamp(-128, 127).toInt();
          return [r, g, b];
        },
      ),
    );
  } else {
    // Standard floating-point 32-bit tensor buffer: shape [height, width, 3], range [-1.0, 1.0]
    final mean = payload.mean;
    final std = payload.std;

    return List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          final p = resized.getPixel(x, y);
          final r = ((p.r - mean) / std).clamp(-1.0, 1.0);
          final g = ((p.g - mean) / std).clamp(-1.0, 1.0);
          final b = ((p.b - mean) / std).clamp(-1.0, 1.0);
          return [r, g, b];
        },
      ),
    );
  }
}

/// Production implementation of [ImagePreprocessor] leveraging background isolates.
class IsolateImagePreprocessor implements ImagePreprocessor {
  double? _lastDurationMs;

  @override
  double? get lastPreprocessDurationMs => _lastDurationMs;

  @override
  Future<dynamic> preprocess(
    Uint8List jpegBytes, {
    PreprocessOptions options = const PreprocessOptions(),
  }) async {
    final sw = Stopwatch()..start();

    final payload = _PreprocessPayload(
      jpegBytes: jpegBytes,
      targetWidth: options.targetWidth,
      targetHeight: options.targetHeight,
      isQuantized: options.isQuantized,
      mean: options.mean,
      std: options.std,
    );

    final tensor = await compute(_preprocessIsolate, payload);
    sw.stop();
    _lastDurationMs = sw.elapsedMicroseconds / 1000.0;

    return tensor;
  }
}

