import '../models/benchmark_result.dart';

/// Abstract service to execute on-device latency benchmarking.
///
/// Follows Section 8 benchmarking methodology:
/// - Executes identical warm-up runs (not counted) followed by timed iterations.
/// - Measures isolated interpreter invocation time (excluding preprocessing/IO).
/// - Calculates mean, median, min, max, standard deviation.
/// - Gathers device platform details and model asset file sizes.
abstract class BenchmarkService {
  /// Stream reporting benchmark progress from 0.0 to 1.0.
  Stream<double> get progressStream;

  /// Current benchmarking progress fraction (0.0 to 1.0).
  double get currentProgress;

  /// Whether a benchmark session is actively running.
  bool get isRunning;

  /// Runs the full benchmark protocol across both model variants.
  Future<BenchmarkResult> runBenchmark({
    int runs = 50,
    int warmupRuns = 10,
  });

  /// Releases resources.
  void dispose();
}

