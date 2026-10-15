import '../models/sensor_reading.dart';

/// Abstract service interface for wireless IoT probe communication.
/// Interface owned by Member C; hardware implementation owned by Member B.
abstract class SensorBleService {
  /// Stream emitting real-time physical readings from the probe.
  Stream<SensorReading> get readingsStream;

  /// Returns the most recently received sensor reading.
  SensorReading? get currentReading;

  /// Connection state of the wireless probe.
  bool get isConnected;

  /// Connects to the ESP32 probe over BLE / Wi-Fi.
  Future<void> connect();

  /// Disconnects from the probe.
  Future<void> disconnect();
}

