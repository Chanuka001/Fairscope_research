import '../models/prediction.dart';

/// Metadata describing an interpreter tensor.
class TensorInfo {
  final String name;
  final List<int> shape;
  final String type;

  const TensorInfo({
    required this.name,
    required this.shape,
    required this.type,
  });

  @override
  String toString() => '$name: shape=$shape, type=$type';
}

/// Abstract runner service for on-device TFLite model execution.
abstract class ModelRunnerService {
  /// Whether the TFLite interpreter is successfully initialized and ready.
  bool get isLoaded;

  /// Active model variant identifier (e.g. 'baseline_fp32' or 'quantized_int8').
  String? get currentVariant;

  /// Input tensor metadata from the loaded interpreter.
  TensorInfo? get inputTensorInfo;

  /// Output tensor metadata from the loaded interpreter.
  TensorInfo? get outputTensorInfo;

  /// Loads the specified TFLite model asset.
  Future<void> loadModel(String variant);

  /// Executes inference on prepared tensor input.
  /// Runs off the main UI thread.
  Future<Prediction> runInference(dynamic inputTensor);

  /// Measures isolated model inference latency in milliseconds over repeated iterations.
  Future<List<double>> measureInferenceTimes(
    dynamic inputTensor, {
    int iterations = 50,
    int warmupIterations = 10,
    void Function(int current, int total)? onProgress,
  });

  /// Releases TFLite interpreter and native memory allocations.
  Future<void> dispose();
}

