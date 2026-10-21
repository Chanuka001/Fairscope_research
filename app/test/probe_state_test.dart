import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/core/services/probe_service.dart';
import 'package:fairscope_app/core/state/probe_state.dart';

void main() {
  group('Probe and Captures Riverpod State tests', () {
    test('Simulated button press adds capture card, sixth drops oldest', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially empty
      expect(container.read(pendingCapturesProvider), isEmpty);

      // Connect probe
      await container.read(probeStatusProvider.notifier).connect();
      expect(container.read(probeStatusProvider), ProbeConnectionStatus.connected);

      // Trigger 5 simulated button presses
      final notifier = container.read(pendingCapturesProvider.notifier);
      for (int i = 0; i < 5; i++) {
        await notifier.simulateDeviceButton();
      }

      var captures = container.read(pendingCapturesProvider);
      expect(captures.length, 5);
      final firstCaptureId = captures.last.id; // oldest capture is at the end

      // Trigger sixth capture
      await notifier.simulateDeviceButton();
      captures = container.read(pendingCapturesProvider);

      expect(captures.length, 5);
      // The oldest capture should have been evicted
      expect(captures.any((c) => c.id == firstCaptureId), isFalse);

      // Test remove capture
      final idToRemove = captures.first.id;
      notifier.removeCapture(idToRemove);
      captures = container.read(pendingCapturesProvider);
      expect(captures.length, 4);
      expect(captures.any((c) => c.id == idToRemove), isFalse);

      // Test clear
      notifier.clear();
      expect(container.read(pendingCapturesProvider), isEmpty);
    });
  });
}

