import '../models/benchmark_result.dart';

/// Abstract service interface for measuring on-device model performance.
/// Owned by Member C. Implements rigorous benchmarking per Section 6.
abstract class BenchmarkService {
  /// Runs warmup and timed inference loops across both fp32 and int8 variants.
  /// Measures interpreter-only latency, file size, and computes statistics.
  Future<BenchmarkReport> runBenchmark({
    int runs = 50,
    int warmupRuns = 10,
    List<List<List<double>>>? testInput,
    void Function(double progress, String status)? onProgress,
  });
}
