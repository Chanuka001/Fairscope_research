import '../models/benchmark_result.dart';

/// Abstract repository interface for persisting and loading research results.
/// Owned by Member C. Loads JSON files from disk and assets.
abstract class ResultsRepository {
  /// Loads the most recent benchmark run report from local storage or bundled assets.
  Future<BenchmarkReport?> loadLatestBenchmark();

  /// Saves a new benchmark report to local JSON storage for export.
  Future<void> saveBenchmarkReport(BenchmarkReport report);

  /// Loads sample or offline fairness audit results across Fitzpatrick skin types.
  Future<Map<String, dynamic>> loadFairnessResults();
}

