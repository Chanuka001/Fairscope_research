import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensor_reading.dart';
import 'mock_sensor_ble_service.dart';
import 'sensor_ble_service.dart';

/// Provides the active SensorBleService (Mock for PP1, easily swappable for real BLE later).
final sensorServiceProvider = Provider<SensorBleService>((ref) {
  final service = MockSensorBleService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Stream of real-time sensor readings from the probe.
final sensorReadingStreamProvider = StreamProvider<SensorReading>((ref) {
  final service = ref.watch(sensorServiceProvider);
  return service.readingsStream;
});

