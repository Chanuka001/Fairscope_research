import '../config/probe_config.dart';
import '../models/capture.dart';
import 'capture_store.dart';

/// In-memory implementation of [CaptureStore] per Section 2 & 3 of FairScope spec.
///
/// Holds up to [ProbeConfig.maxPendingCaptures] (5) unanalysed pending captures.
/// The newest capture is placed at index 0. A sixth capture evicts the oldest.
class InMemoryCaptureStore implements CaptureStore {
  final int maxCaptures;
  final List<Capture> _captures = [];

  InMemoryCaptureStore({int? maxCaptures})
      : maxCaptures = maxCaptures ?? ProbeConfig.maxPendingCaptures;

  @override
  List<Capture> get pendingCaptures => List.unmodifiable(_captures);

  @override
  void addCapture(Capture capture) {
    // Insert newest at index 0
    _captures.insert(0, capture);

    // Evict oldest if exceeding max capacity
    while (_captures.length > maxCaptures) {
      _captures.removeLast();
    }
  }

  @override
  bool removeCapture(String id) {
    final index = _captures.indexWhere((c) => c.id == id);
    if (index != -1) {
      _captures.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Capture? getCaptureById(String id) {
    try {
      return _captures.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void clear() {
    _captures.clear();
  }
}

