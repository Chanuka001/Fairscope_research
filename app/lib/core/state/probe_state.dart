import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';
import '../models/scan_record.dart';
import '../services/capture_store.dart';
import '../services/in_memory_capture_store.dart';
import '../services/http_probe_service.dart';
import '../services/mock_probe_service.dart';
import '../services/probe_service.dart';

/// Notifier controlling whether the app uses Mock Hardware or Real ESP32-CAM HTTP probe.
class MockProbeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setMock(bool isMock) => state = isMock;
}

final isMockProbeProvider =
    NotifierProvider<MockProbeNotifier, bool>(MockProbeNotifier.new);

/// Provider for the singleton [ProbeService] instance (Mock or real HTTP probe).
final probeServiceProvider = Provider<ProbeService>((ref) {
  final isMock = ref.watch(isMockProbeProvider);
  final service = isMock ? MockProbeService() : HttpProbeService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the singleton in-memory [CaptureStore].
final captureStoreProvider = Provider<CaptureStore>((ref) {
  return InMemoryCaptureStore();
});

/// Notifier tracking real-time probe connection status.
class ProbeStatusNotifier extends Notifier<ProbeConnectionStatus> {
  StreamSubscription<ProbeConnectionStatus>? _sub;

  @override
  ProbeConnectionStatus build() {
    final probe = ref.watch(probeServiceProvider);
    _sub?.cancel();
    _sub = probe.connectionStatus.listen((status) {
      state = status;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return probe.currentStatus;
  }

  Future<void> connect() async {
    final probe = ref.read(probeServiceProvider);
    state = ProbeConnectionStatus.connecting;
    await probe.connect();
    state = probe.currentStatus;
  }

  Future<void> disconnect() async {
    final probe = ref.read(probeServiceProvider);
    await probe.disconnect();
    state = probe.currentStatus;
  }
}

final probeStatusProvider =
    NotifierProvider<ProbeStatusNotifier, ProbeConnectionStatus>(
  ProbeStatusNotifier.new,
);

/// Notifier managing pending captures held in memory for Step 1.
class PendingCapturesNotifier extends Notifier<List<Capture>> {
  StreamSubscription<Capture>? _captureSub;

  @override
  List<Capture> build() {
    final probe = ref.watch(probeServiceProvider);
    final store = ref.watch(captureStoreProvider);

    _captureSub?.cancel();
    _captureSub = probe.captures.listen((capture) {
      store.addCapture(capture);
      state = List.from(store.pendingCaptures);
    });

    ref.onDispose(() {
      _captureSub?.cancel();
    });

    return List.from(store.pendingCaptures);
  }

  /// Removes and purges a pending capture.
  void removeCapture(String id) {
    final store = ref.read(captureStoreProvider);
    store.removeCapture(id);
    state = List.from(store.pendingCaptures);
  }

  /// Simulates hardware trigger button press on probe.
  Future<void> simulateDeviceButton() async {
    final probe = ref.read(probeServiceProvider);
    if (probe.currentStatus != ProbeConnectionStatus.connected) {
      await probe.connect();
    }
    await probe.triggerSimulatedCapture();
    await Future<void>.delayed(Duration.zero);
  }

  /// Clears all pending captures from memory.
  void clear() {
    final store = ref.read(captureStoreProvider);
    store.clear();
    state = [];
  }
}

final pendingCapturesProvider =
    NotifierProvider<PendingCapturesNotifier, List<Capture>>(
  PendingCapturesNotifier.new,
);

/// Currently selected capture moving into Step 2 for model analysis.
class SelectedCaptureNotifier extends Notifier<Capture?> {
  @override
  Capture? build() => null;

  void select(Capture? capture) {
    state = capture;
  }

  void clear() {
    state = null;
  }
}

final selectedCaptureProvider =
    NotifierProvider<SelectedCaptureNotifier, Capture?>(
  SelectedCaptureNotifier.new,
);

/// Currently active scan record being viewed across steps 2-4.
class SelectedRecordNotifier extends Notifier<ScanRecord?> {
  @override
  ScanRecord? build() => null;

  void select(ScanRecord? record) {
    state = record;
  }

  void clear() {
    state = null;
  }
}

final selectedRecordProvider =
    NotifierProvider<SelectedRecordNotifier, ScanRecord?>(
  SelectedRecordNotifier.new,
);

