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
    'assets/images/avatas/user_avatar_type_I.png',
    'assets/images/avatas/user_avatar_type_II.png',
    'assets/images/avatas/user_avatar_type_III.png',
    'assets/images/avatas/user_avatar_type_IV.png',
    'assets/images/avatas/user_avatar_type_V.png',
    'assets/images/avatas/user_avatar_type_VI.png',
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

    // Generate realistic skin sensor telemetry
    final reading = SensorReading(
      moisture: 38.0 + ((index * 5.2) % 24.0),
      temperature: 32.4 + ((index * 0.3) % 2.1),
      colorIndex: 1 + (index % 6),
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

