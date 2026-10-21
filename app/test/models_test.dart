import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/core/models/models.dart';
import 'package:fairscope_app/core/config/model_config.dart';
import 'package:fairscope_app/core/config/probe_config.dart';

void main() {
  group('SensorReading model tests', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final reading = SensorReading(
        moisture: 45.2,
        temperature: 32.5,
        colorIndex: 3,
        timestamp: now,
      );

      final json = reading.toJson();
      expect(json['moisture'], 45.2);
      expect(json['temperature'], 32.5);
      expect(json['color_index'], 3);

      final deserialized = SensorReading.fromJson(json);
      expect(deserialized, equals(reading));
    });
  });

  group('Capture model tests', () {
    test('calculates size formatting and serializes image correctly', () {
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final capture = Capture(
        id: 'CAP-TEST-001',
        imageBytes: imageBytes,
        sensorReading: SensorReading(
          moisture: 50.0,
          temperature: 31.0,
          colorIndex: 2,
          timestamp: DateTime(2026, 10, 19, 1, 0),
        ),
        receivedTime: DateTime(2026, 10, 19, 1, 0, 1),
        transferMs: 140,
      );

      expect(capture.imageSizeBytes, 10);
      expect(capture.formattedImageSize.contains('KB'), isTrue);

      final json = capture.toJson();
      expect(json['id'], 'CAP-TEST-001');
      expect(json['transfer_ms'], 140);
      expect(base64Decode(json['image_bytes_base64'] as String), imageBytes);

      final deserialized = Capture.fromJson(json);
      expect(deserialized.id, capture.id);
      expect(deserialized.transferMs, capture.transferMs);
      expect(deserialized.imageBytes, equals(imageBytes));
    });
  });

  group('Prediction model tests', () {
    test('formats confidence and handles probabilities', () {
      final prediction = Prediction(
        label: 'Benign Keratosis',
        confidence: 0.885,
        classProbabilities: {
          'Benign Keratosis': 0.885,
          'Melanocytic Nevi': 0.115,
        },
      );

      expect(prediction.formattedConfidence, '88.5%');

      final json = prediction.toJson();
      final deserialized = Prediction.fromJson(json);
      expect(deserialized.label, 'Benign Keratosis');
      expect(deserialized.confidence, closeTo(0.8845, 0.001));
      expect(deserialized.classProbabilities?['Melanocytic Nevi'], closeTo(0.1155, 0.001));
    });
  });

  group('ScanRecord model tests', () {
    test('manages timings and serialization', () {
      final capture = Capture(
        id: 'CAP-01',
        imageBytes: Uint8List(20),
        sensorReading: SensorReading(
          moisture: 40.0,
          temperature: 30.0,
          colorIndex: 1,
          timestamp: DateTime(2026, 10, 19),
        ),
        receivedTime: DateTime(2026, 10, 19),
      );

      final record = ScanRecord(
        id: 'FS-0001',
        label: 'Cheek scan',
        capture: capture,
        prediction: const Prediction(label: 'Healthy Skin', confidence: 0.94),
        timings: {'inference_ms': 18.2, 'preprocess_ms': 4.5, 'total_ms': 22.7},
        modelVariant: 'quantized_int8',
        createdAt: DateTime(2026, 10, 19),
      );

      expect(record.inferenceMs, 18.2);
      expect(record.preprocessMs, 4.5);
      expect(record.totalDurationMs, 22.7);

      final json = record.toJson();
      final deserialized = ScanRecord.fromJson(json);
      expect(deserialized.id, 'FS-0001');
      expect(deserialized.label, 'Cheek scan');
      expect(deserialized.modelVariant, 'quantized_int8');
    });
  });

  group('BenchmarkResult model tests', () {
    test('computes speedup and size reduction ratios accurately', () {
      const fp32 = BenchmarkVariant(
        name: 'baseline_fp32',
        sizeMb: 16.4,
        latencyMs: BenchmarkLatency(mean: 45.0, median: 44.5, min: 40.0, max: 55.0, std: 2.1),
      );
      const int8 = BenchmarkVariant(
        name: 'quantized_int8',
        sizeMb: 4.1,
        latencyMs: BenchmarkLatency(mean: 15.0, median: 14.8, min: 13.0, max: 20.0, std: 1.2),
      );

      final benchmark = BenchmarkResult(
        device: 'Pixel 8',
        androidVersion: '14',
        date: '2026-10-19',
        modelVersion: 'standin_mobilenet',
        probe: 'mock',
        runs: 50,
        warmupRuns: 10,
        pipelineMs: const PipelineTiming(preprocessMean: 6.2),
        variants: const [fp32, int8],
      );

      expect(benchmark.baselineFp32?.name, 'baseline_fp32');
      expect(benchmark.quantizedInt8?.name, 'quantized_int8');
      expect(benchmark.speedupMultiplier, closeTo(3.0, 0.01)); // 45.0 / 15.0 = 3.0x
      expect(benchmark.sizeReductionPercent, closeTo(75.0, 0.1)); // (16.4 - 4.1) / 16.4 = 75.0%

      final json = benchmark.toJson();
      final deserialized = BenchmarkResult.fromJson(json);
      expect(deserialized.runs, 50);
      expect(deserialized.device, 'Pixel 8');
      expect(deserialized.speedupMultiplier, closeTo(3.0, 0.01));
    });
  });

  group('Config tests', () {
    test('ModelConfig has required asset paths and dimensions', () {
      expect(ModelConfig.baselineFp32Path, contains('.tflite'));
      expect(ModelConfig.quantizedInt8Path, contains('.tflite'));
      expect(ModelConfig.labelsPath, contains('.txt'));
      expect(ModelConfig.inputWidth, 224);
      expect(ModelConfig.inputHeight, 224);
    });

    test('ProbeConfig defines max pending captures as 5', () {
      expect(ProbeConfig.maxPendingCaptures, 5);
    });
  });
}

