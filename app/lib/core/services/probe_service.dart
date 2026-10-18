import '../models/capture.dart';

/// Connection states for the wireless probe hardware.
enum ProbeConnectionStatus {
  /// Probe hardware is powered off or disconnected.
  off,

  /// Establishing connection handshake.
  connecting,

  /// Probe is paired and actively connected.
  connected,

  /// Probe connection dropped or timed out unexpectedly.
  lost,

  /// Hardware or network error encountered.
  error,
}

/// Abstract contract for communicating with the ESP32-CAM wireless skin probe.
///
/// Implementations handle device discovery, connection state streams,
/// and streaming multimodal capture packets pushed when the user presses
/// the physical device trigger button.
abstract class ProbeService {
  /// Stream emitting probe connection state updates.
  Stream<ProbeConnectionStatus> get connectionStatus;

  /// Current synchronous probe connection status.
  ProbeConnectionStatus get currentStatus;

  /// Stream of multimodal captures pushed by the probe button.
  Stream<Capture> get captures;

  /// Initiates connection sequence to the probe.
  Future<void> connect();

  /// Gracefully terminates connection to the probe.
  Future<void> disconnect();

  /// Triggers a simulated capture push in mock mode.
  Future<void> triggerSimulatedCapture();

  /// Releases resources and closes active streams.
  Future<void> dispose();
}

