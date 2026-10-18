import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/core/models/capture.dart';
import 'package:fairscope_app/core/services/http_probe_service.dart';
import 'package:fairscope_app/core/services/mock_probe_service.dart';
import 'package:fairscope_app/core/services/probe_service.dart';
import 'package:fairscope_app/core/state/probe_state.dart';

void main() {
  group('HttpProbeService tests', () {
    test('initial status is off', () {
      final service = HttpProbeService(baseUrl: 'http://127.0.0.1:9999');
      expect(service.currentStatus, equals(ProbeConnectionStatus.off));
      service.dispose();
    });

    test('connect to unreachable endpoint handles error gracefully without throwing', () async {
      final service = HttpProbeService(
        baseUrl: 'http://127.0.0.1:65530',
        timeout: const Duration(milliseconds: 200),
      );

      final statuses = <ProbeConnectionStatus>[];
      final sub = service.connectionStatus.listen(statuses.add);

      await service.connect();

      expect(statuses, contains(ProbeConnectionStatus.connecting));
      expect(statuses, contains(ProbeConnectionStatus.error));
      expect(service.currentStatus, equals(ProbeConnectionStatus.error));

      await service.disconnect();
      expect(service.currentStatus, equals(ProbeConnectionStatus.off));

      await sub.cancel();
      await service.dispose();
    });

    test('isMockProbeProvider switches between MockProbeService and HttpProbeService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Default is mock
      expect(container.read(isMockProbeProvider), isTrue);
      expect(container.read(probeServiceProvider), isA<MockProbeService>());

      // Toggle to real probe
      container.read(isMockProbeProvider.notifier).setMock(false);
      expect(container.read(isMockProbeProvider), isFalse);
      expect(container.read(probeServiceProvider), isA<HttpProbeService>());

      // Toggle back to mock
      container.read(isMockProbeProvider.notifier).setMock(true);
      expect(container.read(isMockProbeProvider), isTrue);
      expect(container.read(probeServiceProvider), isA<MockProbeService>());
    });

    test('Capture JSON parsing works seamlessly for probe data packets', () {
      final json = {
        'id': 'CAP-998877',
        'image_bytes_base64': base64Encode([1, 2, 3, 4, 5]),
        'sensor_reading': {
          'moisture': 44.5,
          'temperature': 33.1,
          'color_index': 3,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'received_time': DateTime.now().toIso8601String(),
        'transfer_ms': 142,
      };

      final capture = Capture.fromJson(json);
      expect(capture.id, equals('CAP-998877'));
      expect(capture.imageBytes, equals([1, 2, 3, 4, 5]));
      expect(capture.sensorReading.moisture, equals(44.5));
      expect(capture.sensorReading.temperature, equals(33.1));
      expect(capture.sensorReading.colorIndex, equals(3));
      expect(capture.transferMs, equals(142));
    });
  });
}

