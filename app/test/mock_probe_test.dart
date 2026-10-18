import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/core/services/mock_probe_service.dart';
import 'package:fairscope_app/core/services/probe_service.dart';

void main() {
  group('MockProbeService tests', () {
    late MockProbeService probe;

    setUp(() {
      probe = MockProbeService(connectionDelay: const Duration(milliseconds: 20));
    });

    tearDown(() async {
      await probe.dispose();
    });

    test('initial status is off', () {
      expect(probe.currentStatus, ProbeConnectionStatus.off);
    });

    test('connection sequence transitions from off to connecting to connected', () async {
      final statuses = <ProbeConnectionStatus>[];
      final sub = probe.connectionStatus.listen(statuses.add);

      expect(probe.currentStatus, ProbeConnectionStatus.off);
      final connectFuture = probe.connect();

      // Immediately should emit connecting
      expect(probe.currentStatus, ProbeConnectionStatus.connecting);

      await connectFuture;
      await Future<void>.delayed(Duration.zero);

      // After latency delay, should be connected
      expect(probe.currentStatus, ProbeConnectionStatus.connected);
      expect(statuses, [
        ProbeConnectionStatus.connecting,
        ProbeConnectionStatus.connected,
      ]);

      await sub.cancel();
    });

    test('disconnect transitions to off', () async {
      await probe.connect();
      expect(probe.currentStatus, ProbeConnectionStatus.connected);

      await probe.disconnect();
      expect(probe.currentStatus, ProbeConnectionStatus.off);
    });

    test('triggerSimulatedCapture throws if probe is not connected', () async {
      expect(
        () => probe.triggerSimulatedCapture(),
        throwsA(isA<StateError>()),
      );
    });

    test('triggerSimulatedCapture emits valid Capture when connected', () async {
      await probe.connect();

      final captureFuture = probe.captures.first;
      await probe.triggerSimulatedCapture();
      final capture = await captureFuture;

      expect(capture.id, startsWith('CAP-'));
      expect(capture.imageBytes.isNotEmpty, isTrue);
      expect(capture.sensorReading.moisture, greaterThan(0));
      expect(capture.sensorReading.temperature, greaterThan(25.0));
      expect(capture.sensorReading.colorIndex, inInclusiveRange(1, 6));
      expect(capture.transferMs, isNotNull);
      expect(capture.transferMs!, greaterThan(0));
    });
  });
}

