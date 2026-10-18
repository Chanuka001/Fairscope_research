import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capture.dart';
import '../models/prediction.dart';
import '../models/scan_record.dart';
import '../services/file_history_repository.dart';
import '../services/history_repository.dart';
import 'model_state.dart';
import 'nav_state.dart';
import 'probe_state.dart';

/// Provider for the singleton [HistoryRepository].
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return FileHistoryRepository();
});

/// Search query for filtering the History list.
class HistorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final historySearchProvider =
    NotifierProvider<HistorySearchNotifier, String>(HistorySearchNotifier.new);

/// State management for the list of persisted [ScanRecord]s.
class HistoryNotifier extends AsyncNotifier<List<ScanRecord>> {
  @override
  Future<List<ScanRecord>> build() async {
    final repo = ref.watch(historyRepositoryProvider);
    return await repo.getAllRecords();
  }

  /// Reloads all records from private storage.
  Future<void> reload() async {
    final repo = ref.read(historyRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.getAllRecords());
  }

  /// Saves an analysed capture as a new [ScanRecord] in private storage.
  Future<ScanRecord> saveAnalysedScan({
    required Capture capture,
    required Prediction prediction,
    required double? preprocessMs,
    required double? inferenceMs,
    required String modelVariant,
    String? label,
  }) async {
    final repo = ref.read(historyRepositoryProvider);
    final autoId = await repo.nextRecordId();

    final record = ScanRecord(
      id: autoId,
      label: label,
      capture: capture,
      prediction: prediction,
      timings: {
        'preprocess_ms': preprocessMs ?? 0.0,
        'inference_ms': inferenceMs ?? 0.0,
        'total_ms': (preprocessMs ?? 0.0) + (inferenceMs ?? 0.0),
      },
      modelVariant: modelVariant,
      createdAt: DateTime.now(),
    );

    final savedRecord = await repo.saveRecord(record).then((_) => record);
    ref.read(currentScanIdProvider.notifier).setId(savedRecord.id);
    await reload();
    return savedRecord;
  }

  /// Renames / updates the optional anonymized label for a record.
  Future<void> updateLabel(String id, String newLabel) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.updateLabel(id, newLabel.trim());
    await reload();
  }

  /// Permanently deletes a record and its storage file.
  Future<void> deleteRecord(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.deleteRecord(id);
    if (ref.read(currentScanIdProvider) == id) {
      ref.read(currentScanIdProvider.notifier).setId(null);
    }
    await reload();
  }

  /// Opens a saved [ScanRecord] into the Analyse flow (Steps 2 to 4).
  void openRecord(ScanRecord record) {
    // 0. Track open scan ID
    ref.read(currentScanIdProvider.notifier).setId(record.id);

    // 1. Set capture into active probe state
    ref.read(selectedCaptureProvider.notifier).select(record.capture);

    // 2. Set active model variant
    ref.read(activeModelVariantProvider.notifier).setVariant(record.modelVariant);

    // 3. Inject saved analysis results
    ref.read(analysisProvider.notifier).setResult(
          prediction: record.prediction,
          preprocessMs: record.preprocessMs,
          inferenceMs: record.inferenceMs,
        );

    // 4. Navigate directly to Step 2 in Analyse tab
    final nav = ref.read(navigationControllerProvider);
    nav.setTab(0);
    nav.goToStep(2);
  }
}

/// Tracks the active [ScanRecord.id] being viewed or just analysed on Step 2.
class CurrentScanIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setId(String? id) => state = id;
}

final currentScanIdProvider =
    NotifierProvider<CurrentScanIdNotifier, String?>(CurrentScanIdNotifier.new);

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<ScanRecord>>(
  HistoryNotifier.new,
);

/// Filtered records according to the search query.
final filteredHistoryRecordsProvider = Provider<List<ScanRecord>>((ref) {
  final historyAsync = ref.watch(historyProvider);
  final query = ref.watch(historySearchProvider).trim().toLowerCase();

  return historyAsync.maybeWhen(
    data: (records) {
      if (query.isEmpty) return records;
      return records.where((r) {
        final matchId = r.id.toLowerCase().contains(query);
        final matchLabel = r.label?.toLowerCase().contains(query) ?? false;
        final matchCond = r.prediction.label.toLowerCase().contains(query);
        return matchId || matchLabel || matchCond;
      }).toList();
    },
    orElse: () => const [],
  );
});
