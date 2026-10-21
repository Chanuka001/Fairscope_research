/// Configuration constants for ESP32-CAM wireless probe communication.
///
/// Records agreed protocol parameters established with Member B (hardware lead).
class ProbeConfig {
  ProbeConfig._();

  /// Maximum number of unanalysed pending captures held in memory.
  static const int maxPendingCaptures = 5;

  /// Default camera image capture width from OV2640 sensor.
  static const int defaultImageWidth = 640;

  /// Default camera image capture height from OV2640 sensor.
  static const int defaultImageHeight = 480;

  /// Probe connection handshake timeout in seconds.
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// Keep-alive ping interval in seconds.
  static const Duration pingInterval = Duration(seconds: 3);

  /// Default HTTP port for probe local access point (Wi-Fi mode).
  static const int defaultProbePort = 80;

  /// Default base URL for ESP32-CAM probe AP mode.
  static const String defaultProbeBaseUrl = 'http://192.168.4.1';

  /// Probe push endpoint where probe sends captured frames and sensor readings.
  static const String pushEndpoint = '/api/capture';

  /// Probe status endpoint for health checks.
  static const String statusEndpoint = '/api/status';

  /// Display text for mock mode indicator.
  static const String mockModeBadge = 'Mock Hardware';
}

