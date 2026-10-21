import '../models/capture.dart';

/// Abstract in-memory storage contract for pending captures in Step 1.
///
/// Rules per specification:
/// - Maintains up to 5 pending captures, newest first.
/// - When a 6th capture arrives, the oldest capture is automatically dropped.
/// - Pending captures reside in volatile memory and are cleared when app closes.
/// - Only analysed captures are ever committed to permanent History.
abstract class CaptureStore {
  /// Ordered list of pending captures (newest at index 0).
  List<Capture> get pendingCaptures;

  /// Adds a new capture to the store.
  /// If the capacity (5) is exceeded, the oldest capture is evicted.
  void addCapture(Capture capture);

  /// Removes and purges a capture by its temporary ID.
  bool removeCapture(String id);

  /// Retrieves a pending capture by its ID.
  Capture? getCaptureById(String id);

  /// Clears all pending captures from memory.
  void clear();
}

