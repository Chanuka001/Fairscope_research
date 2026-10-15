import '../models/model_variant.dart';
import '../models/prediction.dart';
import '../models/sensor_reading.dart';

/// Abstract service interface for on-device TFLite model inference.
/// Owned by Member C. Implemented with tflite_flutter.
abstract class ModelRunnerService {
  /// Loads and prepares the TFLite interpreter for the given or both variants.
  Future<void> initialize();

  /// Runs inference on an image input (and optional sensor reading for multimodal fusion).
  /// Measures and returns inference latency, confidence, and predicted class.
  Future<Prediction> runInference({
    required List<List<List<double>>> inputTensor,
    required ModelVariant variant,
    SensorReading? sensorReading,
  });

  /// Releases interpreter native memory.
  void dispose();
}

