import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/benchmark_result.dart';
import '../services/model_providers.dart';

enum BenchmarkStatus { initial, running, completed, error }

/// State model for model benchmarking
class BenchmarkState {
  final BenchmarkStatus status;
  final double progress;
  final String progressMessage;
  final BenchmarkReport? report;
  final String? errorMessage;

  const BenchmarkState({
    this.status = BenchmarkStatus.initial,
    this.progress = 0.0,
    this.progressMessage = '',
    this.report,
    this.errorMessage,
  });

  BenchmarkState copyWith({
    BenchmarkStatus? status,
    double? progress,
    String? progressMessage,
    BenchmarkReport? report,
    String? errorMessage,
  }) {
    return BenchmarkState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      progressMessage: progressMessage ?? this.progressMessage,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Riverpod Notifier orchestrating model benchmark runs and state updates
class BenchmarkNotifier extends Notifier<BenchmarkState> {
  @override
  BenchmarkState build() {
    _loadInitialReport();
    return BenchmarkState(
      status: BenchmarkStatus.completed,
      report: BenchmarkReport.sample,
    );
  }

  Future<void> _loadInitialReport() async {
    final repo = ref.read(resultsRepositoryProvider);
    final report = await repo.loadLatestBenchmark();
    if (report != null) {
      state = state.copyWith(
        status: BenchmarkStatus.completed,
        report: report,
      );
    }
  }

  Future<void> runBenchmark({int runs = 50, int warmupRuns = 10}) async {
    if (state.status == BenchmarkStatus.running) return;

    state = state.copyWith(
      status: BenchmarkStatus.running,
      progress: 0.0,
      progressMessage: 'Initializing benchmark...',
      errorMessage: null,
    );

    try {
      final benchmarkService = ref.read(benchmarkServiceProvider);
      final repo = ref.read(resultsRepositoryProvider);

      final report = await benchmarkService.runBenchmark(
        runs: runs,
        warmupRuns: warmupRuns,
        onProgress: (progress, message) {
          state = state.copyWith(
            progress: progress,
            progressMessage: message,
          );
        },
      );

      await repo.saveBenchmarkReport(report);

      state = state.copyWith(
        status: BenchmarkStatus.completed,
        progress: 1.0,
        progressMessage: 'Benchmark complete!',
        report: report,
      );
    } catch (e) {
      state = state.copyWith(
        status: BenchmarkStatus.error,
        errorMessage: 'Benchmark failed: $e',
      );
    }
  }
}

final benchmarkProvider =
    NotifierProvider<BenchmarkNotifier, BenchmarkState>(BenchmarkNotifier.new);
