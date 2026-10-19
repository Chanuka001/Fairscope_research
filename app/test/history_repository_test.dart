import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairscope_app/core/models/capture.dart';
import 'package:fairscope_app/core/models/prediction.dart';
import 'package:fairscope_app/core/models/scan_record.dart';
import 'package:fairscope_app/core/models/sensor_reading.dart';
import 'package:fairscope_app/core/services/file_history_repository.dart';
import 'package:fairscope_app/core/state/history_state.dart';
import 'package:fairscope_app/core/state/model_state.dart';
import 'package:fairscope_app/core/state/nav_state.dart';
import 'package:fairscope_app/core/state/probe_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late FileHistoryRepository repo;

  ScanRecord createSampleRecord({
    required String id,
    String? label,
    required DateTime createdAt,
  }) {
    return ScanRecord(
      id: id,
      label: label,
      capture: Capture(
        id: 'CAP-$id',
        imageBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
        sensorReading: SensorReading(
          moisture: 45.0,
          temperature: 32.5,
          colorIndex: 3,
          timestamp: createdAt,
        ),
        receivedTime: createdAt,
      ),
      prediction: const Prediction(
        label: 'Mild Erythema',
        confidence: 0.89,
        classProbabilities: {'Mild Erythema': 0.89, 'Normal': 0.11},
      ),
      timings: {
        'preprocess_ms': 5.2,
        'inference_ms': 8.4,
        'total_ms': 13.6,
      },
      modelVariant: 'quantized_int8',
      createdAt: createdAt,
    );
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('fairscope_history_test_');
    repo = FileHistoryRepository(customDirectory: tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileHistoryRepository tests', () {
    test('starts with empty list and generates FS-0001 for first record', () async {
      final records = await repo.getAllRecords();
      expect(records.isEmpty, isTrue);

      final nextId = await repo.nextRecordId();
      expect(nextId, 'FS-0001');
    });

    test('saves record, generates sequential nextRecordId, and sorts newest first', () async {
      final r1 = createSampleRecord(
        id: 'FS-0001',
        createdAt: DateTime(2026, 9, 10, 10, 0),
      );
      await repo.saveRecord(r1);

      expect(await repo.nextRecordId(), 'FS-0002');

      final r2 = createSampleRecord(
        id: 'FS-0002',
        createdAt: DateTime(2026, 9, 12, 14, 0),
      );
      await repo.saveRecord(r2);

      expect(await repo.nextRecordId(), 'FS-0003');

      final all = await repo.getAllRecords();
      expect(all.length, 2);
      expect(all.first.id, 'FS-0002'); // Newest first
      expect(all.last.id, 'FS-0001');

      final fetched = await repo.getRecordById('FS-0001');
      expect(fetched, isNotNull);
      expect(fetched!.capture.sensorReading.moisture, 45.0);
      expect(fetched.prediction.label, 'Mild Erythema');
    });

    test('updateLabel updates record without modifying underlying capture data', () async {
      final record = createSampleRecord(
        id: 'FS-0001',
        createdAt: DateTime.now(),
      );
      await repo.saveRecord(record);

      await repo.updateLabel('FS-0001', 'Forehead Scan #1');

      final updated = await repo.getRecordById('FS-0001');
      expect(updated, isNotNull);
      expect(updated!.label, 'Forehead Scan #1');
      expect(updated.capture.imageBytes, equals([1, 2, 3, 4, 5]));
    });

    test('deleteRecord permanently deletes file from disk', () async {
      final record = createSampleRecord(
        id: 'FS-0001',
        createdAt: DateTime.now(),
      );
      await repo.saveRecord(record);

      final deleted = await repo.deleteRecord('FS-0001');
      expect(deleted, isTrue);

      final all = await repo.getAllRecords();
      expect(all.isEmpty, isTrue);

      final fetched = await repo.getRecordById('FS-0001');
      expect(fetched, isNull);
    });
  });

  group('HistoryNotifier & Search Riverpod state tests', () {
    test('saveAnalysedScan, search filter, and openRecord work correctly', () async {
      final container = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(historyProvider.notifier);
      await notifier.saveAnalysedScan(
        capture: Capture(
          id: 'CAP-TEST-1',
          imageBytes: Uint8List.fromList([10, 20, 30]),
          sensorReading: SensorReading(
            moisture: 50.0,
            temperature: 31.0,
            colorIndex: 2,
            timestamp: DateTime.now(),
          ),
          receivedTime: DateTime.now(),
        ),
        prediction: const Prediction(
          label: 'Eczema flare',
          confidence: 0.92,
          classProbabilities: {'Eczema flare': 0.92},
        ),
        preprocessMs: 4.5,
        inferenceMs: 7.8,
        modelVariant: 'quantized_int8',
        label: 'Cheek region',
      );

      final records = container.read(filteredHistoryRecordsProvider);
      expect(records.length, 1);
      expect(records.first.id, 'FS-0001');
      expect(records.first.label, 'Cheek region');

      // Test Search matching
      container.read(historySearchProvider.notifier).setQuery('Cheek');
      expect(container.read(filteredHistoryRecordsProvider).length, 1);

      container.read(historySearchProvider.notifier).setQuery('NonExistent');
      expect(container.read(filteredHistoryRecordsProvider).isEmpty, isTrue);

      container.read(historySearchProvider.notifier).clear();
      expect(container.read(filteredHistoryRecordsProvider).length, 1);

      // Test openRecord
      notifier.openRecord(records.first);

      // Verify opened into analyse state
      expect(container.read(currentScanIdProvider), 'FS-0001');
      expect(container.read(selectedCaptureProvider)?.id, 'CAP-TEST-1');
      expect(container.read(activeModelVariantProvider), 'quantized_int8');
      expect(container.read(analysisProvider).prediction?.label, 'Eczema flare');
      expect(container.read(bottomNavIndexProvider), 0);
      expect(container.read(analyseStepProvider), 2);

      // Test subsequent scan saving after resetting currentScanIdProvider
      container.read(currentScanIdProvider.notifier).setId(null);
      container.read(analysisProvider.notifier).reset();

      final capture2 = Capture(
        id: 'CAP-TEST-2',
        imageBytes: Uint8List.fromList([10, 20, 30]),
        sensorReading: SensorReading(
          moisture: 60.0,
          temperature: 33.0,
          colorIndex: 1,
          timestamp: DateTime.now(),
        ),
        receivedTime: DateTime.now(),
      );
      container.read(selectedCaptureProvider.notifier).select(capture2);

      final secondRecord = await notifier.saveAnalysedScan(
        capture: capture2,
        prediction: const Prediction(
          label: 'Benign Keratosis',
          confidence: 0.88,
        ),
        preprocessMs: 4.0,
        inferenceMs: 6.5,
        modelVariant: 'baseline_fp32',
        label: 'Forehead',
      );

      expect(secondRecord.id, 'FS-0002');
      expect(container.read(currentScanIdProvider), 'FS-0002');

      final updatedRecords = container.read(filteredHistoryRecordsProvider);
      expect(updatedRecords.length, 2);
      expect(updatedRecords.first.id, 'FS-0002');
      expect(updatedRecords.last.id, 'FS-0001');

      // Test back navigation: opening record from History and tapping back returns to History tab (tab 1)
      notifier.openRecord(secondRecord);
      expect(container.read(bottomNavIndexProvider), 0);
      expect(container.read(analyseStepProvider), 2);
      expect(container.read(openedFromHistoryProvider), isTrue);
      expect(container.read(currentScanIdProvider), 'FS-0002');

      final nav = container.read(navigationControllerProvider);
      final handled = nav.handleBack();
      expect(handled, isTrue);
      // Verifies it returns directly to the History tab and resets Analyse step & scan state!
      expect(container.read(bottomNavIndexProvider), 1);
      expect(container.read(openedFromHistoryProvider), isFalse);
      expect(container.read(analyseStepProvider), 1);
      expect(container.read(currentScanIdProvider), isNull);
      expect(container.read(selectedCaptureProvider), isNull);

      // Verifies subsequent tap on Analyse tab opens Step 1 cleanly without re-opening previous record
      nav.setTab(0);
      expect(container.read(bottomNavIndexProvider), 0);
      expect(container.read(analyseStepProvider), 1);
      expect(container.read(currentScanIdProvider), isNull);
    });
  });
}
