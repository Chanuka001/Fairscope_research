import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/capture.dart';
import '../models/sensor_reading.dart';
import 'probe_service.dart';

/// Mock implementation of [ProbeService] for offline development and testing.
///
/// Features:
/// - Realistic connection lifecycle: off -> connecting -> connected (animation timings)
/// - Pushes multimodal [Capture] packets on simulated physical button presses
/// - Cycles through bundled test face images and realistic skin sensor readings
class MockProbeService implements ProbeService {
  final StreamController<ProbeConnectionStatus> _statusController =
      StreamController<ProbeConnectionStatus>.broadcast();

  final StreamController<Capture> _capturesController =
      StreamController<Capture>.broadcast();

  ProbeConnectionStatus _currentStatus = ProbeConnectionStatus.off;
  int _simulationCounter = 0;

  static const List<String> _sampleAssets = [
    'assets/images/clinical/clinical_acne1.jpg',
    'assets/images/clinical/clinical_benign1.jpg',
    'assets/images/clinical/clinical_eczema1.jpg',
    'assets/images/clinical/clinical_melanoma1.jpg',
    'assets/images/clinical/clinical_psoriasis1.jpg',
    'assets/images/clinical/clinical_acne2.jpg',
    'assets/images/clinical/clinical_benign2.jpg',
    'assets/images/clinical/clinical_eczema2.jpg',
    'assets/images/clinical/clinical_melanoma2.jpg',
    'assets/images/clinical/clinical_psoriasis2.jpg',
  ];

  final Duration connectionDelay;

  MockProbeService({this.connectionDelay = const Duration(milliseconds: 500)});

  @override
  Stream<ProbeConnectionStatus> get connectionStatus =>
      _statusController.stream;

  @override
  ProbeConnectionStatus get currentStatus => _currentStatus;

  @override
  Stream<Capture> get captures => _capturesController.stream;

  @override
  Future<void> connect() async {
    if (_currentStatus == ProbeConnectionStatus.connected) return;

    _updateStatus(ProbeConnectionStatus.connecting);

    // Simulate wireless connection handshake latency
    if (connectionDelay > Duration.zero) {
      await Future.delayed(connectionDelay);
    }

    _updateStatus(ProbeConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    _updateStatus(ProbeConnectionStatus.off);
  }

  @override
  Future<void> triggerSimulatedCapture() async {
    if (_currentStatus != ProbeConnectionStatus.connected) {
      throw StateError('Cannot capture: Probe is not connected.');
    }

    final index = _simulationCounter++;
    final assetPath = _sampleAssets[index % _sampleAssets.length];

    Uint8List imageBytes;
    try {
      final byteData = await rootBundle.load(assetPath);
      imageBytes = byteData.buffer.asUint8List();
    } catch (_) {
      // Fallback for isolated headless unit tests without Flutter asset bundle: valid 32x32 image
      final sample = img.Image(width: 32, height: 32);
      img.fill(sample, color: img.ColorRgb8(200, 160, 120));
      imageBytes = Uint8List.fromList(img.encodeJpg(sample));
    }

    // Generate condition-calibrated skin sensor telemetry matching the 5 diagnostic classes
    final mod = index % 5;
    final double moisture;
    final double temperature;
    final int colorIndex;

    switch (mod) {
      case 0: // Acne
        moisture = 37.5 + ((index * 1.3) % 4.0);
        temperature = 32.4 + ((index * 0.2) % 0.8);
        colorIndex = 2;
        break;
      case 1: // Benign Nevus
        moisture = 43.0 + ((index * 1.1) % 5.0);
        temperature = 32.7 + ((index * 0.1) % 0.5);
        colorIndex = 3;
        break;
      case 2: // Eczema (dry skin / reduced hydration barrier)
        moisture = 22.0 + ((index * 1.5) % 4.5);
        temperature = 33.1 + ((index * 0.2) % 0.6);
        colorIndex = 1;
        break;
      case 3: // Melanoma
        moisture = 47.5 + ((index * 1.2) % 4.0);
        temperature = 33.3 + ((index * 0.2) % 0.7);
        colorIndex = 4;
        break;
      case 4: // Psoriasis (scaling / hyperkeratosis)
      default:
        moisture = 28.0 + ((index * 1.4) % 3.5);
        temperature = 32.6 + ((index * 0.2) % 0.5);
        colorIndex = 5;
        break;
    }

    final reading = SensorReading(
      moisture: double.parse(moisture.toStringAsFixed(1)),
      temperature: double.parse(temperature.toStringAsFixed(1)),
      colorIndex: colorIndex,
      timestamp: DateTime.now(),
    );

    final captureId = 'CAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final transferMs = 125 + ((index * 17) % 55);

    final capture = Capture(
      id: captureId,
      imageBytes: imageBytes,
      sensorReading: reading,
      receivedTime: DateTime.now(),
      transferMs: transferMs,
    );

    _capturesController.add(capture);
  }

  void _updateStatus(ProbeConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> dispose() async {
    await _statusController.close();
    await _capturesController.close();
  }
}

