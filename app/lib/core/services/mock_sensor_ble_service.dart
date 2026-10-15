import 'dart:async';
import 'dart:math';
import '../models/sensor_reading.dart';
import 'sensor_ble_service.dart';

/// Mock implementation of SensorBleService simulating real-time telemetry from the ESP32 probe.
/// Used for Progress Presentation 1 while Member B finishes the hardware probe.
class MockSensorBleService implements SensorBleService {
  final _streamController = StreamController<SensorReading>.broadcast();
  Timer? _timer;
  final Random _random = Random();

  bool _isConnected = true;
  SensorReading? _currentReading;

  // Baseline values around which readings realistically fluctuate
  double _moisture = 42.0;
  double _temperature = 32.4;
  int _colorIndex = 128;

  MockSensorBleService({bool autoStart = true}) {
    if (autoStart) {
      connect();
    }
  }

  @override
  Stream<SensorReading> get readingsStream => _streamController.stream;

  @override
  SensorReading? get currentReading => _currentReading;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect() async {
    _isConnected = true;
    _timer?.cancel();

    // Emit initial reading
    _emitReading();

    // Periodically emit readings (every 1 second)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isConnected) {
        _emitReading();
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _timer?.cancel();
    if (_currentReading != null) {
      _currentReading = _currentReading!.copyWith(isConnected: false);
      _streamController.add(_currentReading!);
    }
  }

  void _emitReading() {
    // Smooth random walk
    _moisture = (_moisture + (_random.nextDouble() * 1.6 - 0.8)).clamp(35.0, 55.0);
    _temperature = (_temperature + (_random.nextDouble() * 0.4 - 0.2)).clamp(30.0, 36.0);
    _colorIndex = (_colorIndex + (_random.nextInt(5) - 2)).clamp(110, 150);

    _currentReading = SensorReading(
      timestamp: DateTime.now(),
      moisturePercent: double.parse(_moisture.toStringAsFixed(1)),
      skinTemperature: double.parse(_temperature.toStringAsFixed(1)),
      colorIndex: _colorIndex,
      isConnected: _isConnected,
    );

    if (!_streamController.isClosed) {
      _streamController.add(_currentReading!);
    }
  }

  void dispose() {
    _timer?.cancel();
    _streamController.close();
  }
}
