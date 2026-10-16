import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model_runner_service.dart';
import 'tflite_model_runner_service.dart';
import 'benchmark_service.dart';
import 'tflite_benchmark_service.dart';
import 'results_repository.dart';
import 'local_results_repository.dart';

/// Riverpod provider for on-device ModelRunnerService
final modelRunnerProvider = Provider<ModelRunnerService>((ref) {
  final service = TfliteModelRunnerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Riverpod provider for on-device BenchmarkService
final benchmarkServiceProvider = Provider<BenchmarkService>((ref) {
  return TfliteBenchmarkService();
});

/// Riverpod provider for ResultsRepository
final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  return LocalResultsRepository();
});
