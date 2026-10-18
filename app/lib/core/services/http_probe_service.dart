import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../config/probe_config.dart';
import '../models/capture.dart';
import '../models/sensor_reading.dart';
import 'probe_service.dart';

/// Real HTTP-based implementation of [ProbeService] for the ESP32-CAM wireless skin probe.
///
/// Communicates over local Wi-Fi / SoftAP with the physical ESP32 probe:
/// - Handshakes and monitors heartbeat via [ProbeConfig.statusEndpoint]
/// - Polls or receives capture packets via [ProbeConfig.pushEndpoint]
/// - Robustly handles connection timeouts, probe power-off, and network drops
class HttpProbeService implements ProbeService {
  final String baseUrl;
  final HttpClient _httpClient;
  final Duration pingInterval;
  final Duration timeout;

  final StreamController<ProbeConnectionStatus> _statusController =
      StreamController<ProbeConnectionStatus>.broadcast(sync: true);

  final StreamController<Capture> _capturesController =
      StreamController<Capture>.broadcast(sync: true);

  ProbeConnectionStatus _currentStatus = ProbeConnectionStatus.off;
  Timer? _heartbeatTimer;
  bool _isDisposed = false;

  HttpProbeService({
    String? baseUrl,
    HttpClient? httpClient,
    this.pingInterval = ProbeConfig.pingInterval,
    this.timeout = ProbeConfig.connectionTimeout,
  })  : baseUrl = baseUrl ?? ProbeConfig.defaultProbeBaseUrl,
        _httpClient = httpClient ?? HttpClient();

  @override
  Stream<ProbeConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  ProbeConnectionStatus get currentStatus => _currentStatus;

  @override
  Stream<Capture> get captures => _capturesController.stream;

  @override
  Future<void> connect() async {
    if (_isDisposed) return;
    if (_currentStatus == ProbeConnectionStatus.connected) return;

    _updateStatus(ProbeConnectionStatus.connecting);

    try {
      final uri = Uri.parse('$baseUrl${ProbeConfig.statusEndpoint}');
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);

      if (response.statusCode == 200) {
        // Drain response
        await response.drain<void>();
        _updateStatus(ProbeConnectionStatus.connected);
        _startHeartbeat();
      } else {
        await response.drain<void>();
        _updateStatus(ProbeConnectionStatus.error);
      }
    } catch (_) {
      _updateStatus(ProbeConnectionStatus.error);
    }
  }

  @override
  Future<void> disconnect() async {
    _stopHeartbeat();
    _updateStatus(ProbeConnectionStatus.off);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(pingInterval, (_) => _checkHeartbeat());
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _checkHeartbeat() async {
    if (_currentStatus != ProbeConnectionStatus.connected || _isDisposed) return;

    try {
      final uri = Uri.parse('$baseUrl${ProbeConfig.statusEndpoint}');
      final request = await _httpClient.getUrl(uri).timeout(const Duration(seconds: 2));
      final response = await request.close().timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        await response.drain<void>();
      } else {
        await response.drain<void>();
        _updateStatus(ProbeConnectionStatus.lost);
        _stopHeartbeat();
      }
    } catch (_) {
      _updateStatus(ProbeConnectionStatus.lost);
      _stopHeartbeat();
    }
  }

  /// Fetches the latest capture frame and sensor telemetry from the probe.
  Future<Capture?> fetchLatestCapture() async {
    if (_currentStatus != ProbeConnectionStatus.connected) return null;

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse('$baseUrl${ProbeConfig.pushEndpoint}');
      final request = await _httpClient.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      stopwatch.stop();

      if (response.statusCode != 200) {
        await response.drain<void>();
        return null;
      }

      final contentType = response.headers.contentType?.mimeType ?? '';
      Capture capture;

      if (contentType.contains('json')) {
        final bodyStr = await utf8.decodeStream(response);
        final json = jsonDecode(bodyStr) as Map<String, dynamic>;
        
        Uint8List imageBytes;
        if (json.containsKey('image_bytes_base64')) {
          imageBytes = base64Decode(json['image_bytes_base64'] as String);
        } else {
          imageBytes = Uint8List(0);
        }

        final sensorReading = SensorReading(
          moisture: (json['moisture'] as num?)?.toDouble() ?? 40.0,
          temperature: (json['temperature'] as num?)?.toDouble() ?? 32.5,
          colorIndex: (json['color_index'] as num?)?.toInt() ?? 2,
          timestamp: DateTime.now(),
        );

        capture = Capture(
          id: (json['id'] as String?) ?? 'CAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          imageBytes: imageBytes,
          sensorReading: sensorReading,
          receivedTime: DateTime.now(),
          transferMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        // Raw image response with sensor headers (e.g. image/jpeg)
        final bytesBuilder = BytesBuilder(copy: false);
        await for (final chunk in response) {
          bytesBuilder.add(chunk);
        }
        final imageBytes = bytesBuilder.takeBytes();

        final moistureHeader = response.headers.value('x-sensor-moisture');
        final tempHeader = response.headers.value('x-sensor-temp');
        final colorHeader = response.headers.value('x-sensor-color-index');

        final sensorReading = SensorReading(
          moisture: moistureHeader != null ? (double.tryParse(moistureHeader) ?? 42.0) : 42.0,
          temperature: tempHeader != null ? (double.tryParse(tempHeader) ?? 32.5) : 32.5,
          colorIndex: colorHeader != null ? (int.tryParse(colorHeader) ?? 2) : 2,
          timestamp: DateTime.now(),
        );

        capture = Capture(
          id: 'CAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          imageBytes: imageBytes,
          sensorReading: sensorReading,
          receivedTime: DateTime.now(),
          transferMs: stopwatch.elapsedMilliseconds,
        );
      }

      if (!_isDisposed) {
        _capturesController.add(capture);
      }
      return capture;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> triggerSimulatedCapture() async {
    // In real HTTP probe mode, trigger simulated capture issues a trigger command to the probe
    try {
      final uri = Uri.parse('$baseUrl/api/trigger');
      final request = await _httpClient.postUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      await response.drain<void>();
      await fetchLatestCapture();
    } catch (_) {
      // If hardware trigger endpoint is unavailable, attempt fetch
      await fetchLatestCapture();
    }
  }

  void _updateStatus(ProbeConnectionStatus status) {
    if (_isDisposed) return;
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _stopHeartbeat();
    _httpClient.close(force: true);
    await _statusController.close();
    await _capturesController.close();
  }
}

