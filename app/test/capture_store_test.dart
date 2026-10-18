import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:fairscope_app/core/models/models.dart';
import 'package:fairscope_app/core/services/in_memory_capture_store.dart';

void main() {
  group('InMemoryCaptureStore tests', () {
    late InMemoryCaptureStore store;

    setUp(() {
      store = InMemoryCaptureStore(maxCaptures: 5);
    });

    Capture createDummyCapture(String id) {
      return Capture(
        id: id,
        imageBytes: Uint8List.fromList([1, 2, 3]),
        sensorReading: SensorReading(
          moisture: 45.0,
          temperature: 32.5,
          colorIndex: 1,
          timestamp: DateTime.now(),
        ),
        receivedTime: DateTime.now(),
      );
    }

    test('starts empty', () {
      expect(store.pendingCaptures, isEmpty);
    });

    test('adds captures in newest-first order', () {
      final c1 = createDummyCapture('CAP-1');
      final c2 = createDummyCapture('CAP-2');

      store.addCapture(c1);
      store.addCapture(c2);

      expect(store.pendingCaptures.length, 2);
      expect(store.pendingCaptures[0].id, 'CAP-2');
      expect(store.pendingCaptures[1].id, 'CAP-1');
    });

    test('sixth capture drops the oldest (capacity constraint)', () {
      for (int i = 1; i <= 5; i++) {
        store.addCapture(createDummyCapture('CAP-$i'));
      }
      expect(store.pendingCaptures.length, 5);
      expect(store.pendingCaptures.first.id, 'CAP-5');
      expect(store.pendingCaptures.last.id, 'CAP-1');

      // Add sixth capture
      store.addCapture(createDummyCapture('CAP-6'));

      expect(store.pendingCaptures.length, 5);
      // Newest on top
      expect(store.pendingCaptures.first.id, 'CAP-6');
      // Oldest ('CAP-1') should have been dropped
      expect(store.pendingCaptures.any((c) => c.id == 'CAP-1'), isFalse);
      expect(store.pendingCaptures.last.id, 'CAP-2');
    });

    test('removeCapture removes specific capture by ID', () {
      final c1 = createDummyCapture('CAP-1');
      final c2 = createDummyCapture('CAP-2');
      store.addCapture(c1);
      store.addCapture(c2);

      final removed = store.removeCapture('CAP-1');
      expect(removed, isTrue);
      expect(store.pendingCaptures.length, 1);
      expect(store.pendingCaptures.first.id, 'CAP-2');
    });

    test('getCaptureById finds correct capture or null', () {
      final c1 = createDummyCapture('CAP-1');
      store.addCapture(c1);

      expect(store.getCaptureById('CAP-1')?.id, 'CAP-1');
      expect(store.getCaptureById('CAP-NONEXISTENT'), isNull);
    });

    test('clear removes all pending captures', () {
      store.addCapture(createDummyCapture('CAP-1'));
      store.addCapture(createDummyCapture('CAP-2'));
      expect(store.pendingCaptures.length, 2);

      store.clear();
      expect(store.pendingCaptures, isEmpty);
    });
  });
}

