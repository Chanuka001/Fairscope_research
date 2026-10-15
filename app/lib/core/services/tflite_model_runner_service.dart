import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../config/model_config.dart';
import '../models/model_variant.dart';
import '../models/prediction.dart';
import '../models/sensor_reading.dart';
import 'model_runner_service.dart';

/// Real on-device TFLite model runner supporting both FP32 baseline and INT8 quantized variants.
/// Owned by Member C (Monal).
class TfliteModelRunnerService implements ModelRunnerService {
  Interpreter? _fp32Interpreter;
  Interpreter? _int8Interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load labels from asset
      final labelsData = await rootBundle.loadString(ModelConfig.labelsAsset);
      _labels = labelsData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // 2. Load FP32 baseline interpreter
      _fp32Interpreter = await Interpreter.fromAsset(
        ModelConfig.baselineFp32Asset,
        options: InterpreterOptions()..threads = 4,
      );
      _logTensorDetails(_fp32Interpreter!, 'Baseline FP32');

      // 3. Load INT8 quantized interpreter
      _int8Interpreter = await Interpreter.fromAsset(
        ModelConfig.quantizedInt8Asset,
        options: InterpreterOptions()..threads = 4,
      );
      _logTensorDetails(_int8Interpreter!, 'Quantized INT8');

      _isInitialized = true;
      developer.log('✅ TfliteModelRunnerService initialized successfully', name: 'ModelRunner');
    } catch (e, stack) {
      developer.log('❌ Error initializing TfliteModelRunnerService: $e',
          name: 'ModelRunner', error: e, stackTrace: stack);
      rethrow;
    }
  }

  void _logTensorDetails(Interpreter interpreter, String name) {
    final inTensor = interpreter.getInputTensor(0);
    final outTensor = interpreter.getOutputTensor(0);
    developer.log(
      '[$name] Input: shape=${inTensor.shape}, type=${inTensor.type} | Output: shape=${outTensor.shape}, type=${outTensor.type}',
      name: 'ModelRunner',
    );
  }

  @override
  Future<Prediction> runInference({
    required List<List<List<double>>> inputTensor,
    required ModelVariant variant,
    SensorReading? sensorReading,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final interpreter = variant == ModelVariant.baselineFp32
        ? _fp32Interpreter
        : _int8Interpreter;

    if (interpreter == null) {
      throw StateError('Interpreter for ${variant.displayName} is not loaded.');
    }

    final inTensor = interpreter.getInputTensor(0);
    final outTensor = interpreter.getOutputTensor(0);

    // Prepare input buffer according to input TensorType
    Object input;
    if (inTensor.type == TensorType.float32) {
      input = [inputTensor]; // Shape: [1, 224, 224, 3]
    } else if (inTensor.type == TensorType.int8) {
      // Quantize float values to int8
      final scale = inTensor.params.scale != 0 ? inTensor.params.scale : 1.0;
      final zeroPoint = inTensor.params.zeroPoint;
      final int8Batch = [
        inputTensor.map((row) {
          return row.map((pixel) {
            return pixel.map((channel) {
              return ((channel / scale) + zeroPoint).round().clamp(-128, 127);
            }).toList();
          }).toList();
        }).toList()
      ];
      input = int8Batch;
    } else {
      input = [inputTensor];
    }

    // Allocate output buffer based on output shape
    final numClasses = outTensor.shape.last;
    dynamic outputBuffer;
    if (outTensor.type == TensorType.int8) {
      outputBuffer = [List<int>.filled(numClasses, 0)];
    } else {
      outputBuffer = [List<double>.filled(numClasses, 0.0)];
    }

    // Time ONLY the interpreter call per Section 6
    final stopwatch = Stopwatch()..start();
    interpreter.run(input, outputBuffer);
    stopwatch.stop();

    final latency = stopwatch.elapsed;

    // Post-process probabilities
    final rawScores = outputBuffer[0];
    List<double> probabilities;

    if (outTensor.type == TensorType.int8) {
      final scale = outTensor.params.scale != 0 ? outTensor.params.scale : 1.0;
      final zeroPoint = outTensor.params.zeroPoint;
      probabilities = (rawScores as List<int>).map((val) {
        return (val - zeroPoint) * scale;
      }).toList();
    } else {
      probabilities = (rawScores as List<double>);
    }

    // Softmax normalization if scores are unnormalized logits
    probabilities = _softmax(probabilities);

    // Find highest confidence index
    int maxIdx = 0;
    double maxConfidence = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIdx = i;
      }
    }

    // Assign class label from labels.txt (fallback to index if class count exceeds labels)
    final label = (maxIdx < _labels.length)
        ? _labels[maxIdx]
        : 'Condition Class #$maxIdx';

    final labelProbMap = <String, double>{};
    for (int i = 0; i < _labels.length && i < probabilities.length; i++) {
      labelProbMap[_labels[i]] = probabilities[i];
    }

    return Prediction(
      label: label,
      confidence: maxConfidence,
      variant: variant,
      inferenceLatency: latency,
      timestamp: DateTime.now(),
      allProbabilities: labelProbMap,
      isPlaceholderModel: true,
    );
  }

  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    double maxLogit = logits.reduce((a, b) => a > b ? a : b);
    List<double> exps = logits.map((l) => (l - maxLogit).clamp(-50.0, 50.0)).map((v) => (v == 0) ? 1.0 : (v > 0 ? (1.0 + v) : 1.0 / (1.0 - v))).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    if (sumExps == 0) return List.filled(logits.length, 1.0 / logits.length);
    return exps.map((e) => e / sumExps).toList();
  }

  @override
  void dispose() {
    _fp32Interpreter?.close();
    _int8Interpreter?.close();
    _fp32Interpreter = null;
    _int8Interpreter = null;
    _isInitialized = false;
  }
}
