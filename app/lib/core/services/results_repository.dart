import '../models/benchmark_result.dart';

/// Abstract repository for loading and persisting benchmark reports.
abstract class ResultsRepository {
  /// Loads sample benchmark results from bundled asset JSON.
  Future<BenchmarkResult?> loadSampleBenchmark();

  /// Loads previously executed benchmark results saved on the device.
  Future<BenchmarkResult?> loadLatestSavedBenchmark();

  /// Persists a new benchmark report as JSON to device storage.
  Future<void> saveBenchmark(BenchmarkResult result);
}

