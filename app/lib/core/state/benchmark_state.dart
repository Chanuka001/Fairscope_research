import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/benchmark_result.dart';
import '../services/benchmark_service.dart';
import '../services/tflite_benchmark_service.dart';
import 'model_state.dart';

/// Provider for the [BenchmarkService] singleton engine.
final benchmarkServiceProvider = Provider<BenchmarkService>((ref) {
  final runner = ref.watch(modelRunnerProvider);
  final preprocessor = ref.watch(imagePreprocessorProvider);
  final service = TfliteBenchmarkService(
    modelRunner: runner,
    preprocessor: preprocessor,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// UI state for the benchmark dashboard on Step 4.
class BenchmarkState {
  final bool isRunning;
  final double progress;
  final BenchmarkResult? result;
  final String? error;

  const BenchmarkState({
    this.isRunning = false,
    this.progress = 0.0,
    this.result,
    this.error,
  });

  BenchmarkState copyWith({
    bool? isRunning,
    double? progress,
    BenchmarkResult? result,
    String? error,
  }) {
    return BenchmarkState(
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      error: error,
    );
  }
}

class BenchmarkNotifier extends Notifier<BenchmarkState> {
  StreamSubscription<double>? _progressSub;

  @override
  BenchmarkState build() {
    final service = ref.watch(benchmarkServiceProvider);
    _progressSub?.cancel();
    _progressSub = service.progressStream.listen((progress) {
      state = state.copyWith(progress: progress);
    });

    ref.onDispose(() {
      _progressSub?.cancel();
    });

    return const BenchmarkState();
  }

  Future<BenchmarkResult?> executeBenchmark({
    int runs = 25,
    int warmupRuns = 5,
  }) async {
    final service = ref.read(benchmarkServiceProvider);
    state = state.copyWith(isRunning: true, progress: 0.0, error: null);

    try {
      final res = await service.runBenchmark(
        runs: runs,
        warmupRuns: warmupRuns,
      );
      state = state.copyWith(
        isRunning: false,
        progress: 1.0,
        result: res,
      );
      return res;
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const BenchmarkState();
  }
}

final benchmarkStateProvider =
    NotifierProvider<BenchmarkNotifier, BenchmarkState>(BenchmarkNotifier.new);

