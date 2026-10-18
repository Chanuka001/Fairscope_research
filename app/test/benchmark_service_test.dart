import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairscope_app/core/models/benchmark_result.dart';
import 'package:fairscope_app/core/services/isolate_image_preprocessor.dart';
import 'package:fairscope_app/core/services/tflite_benchmark_service.dart';
import 'package:fairscope_app/core/services/tflite_model_runner_service.dart';
import 'package:fairscope_app/core/state/benchmark_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TfliteBenchmarkService & BenchmarkState tests', () {
    late TfliteBenchmarkService benchmarkService;

    setUp(() {
      final runner = TfliteModelRunnerService();
      final preprocessor = IsolateImagePreprocessor();
      benchmarkService = TfliteBenchmarkService(
        modelRunner: runner,
        preprocessor: preprocessor,
      );
    });

    tearDown(() {
      benchmarkService.dispose();
    });

    test('runBenchmark runs warmup and measured iterations, calculates speedup', () async {
      final progressValues = <double>[];
      final sub = benchmarkService.progressStream.listen(progressValues.add);

      final result = await benchmarkService.runBenchmark(runs: 5, warmupRuns: 2);

      expect(result, isA<BenchmarkResult>());
      expect(result.baselineFp32?.name, 'baseline_fp32');
      expect(result.quantizedInt8?.name, 'quantized_int8');
      expect(result.speedupMultiplier, isNotNull);
      expect(result.speedupMultiplier!, greaterThan(1.0));
      expect(result.sizeReductionPercent, isNotNull);
      expect(result.sizeReductionPercent!, greaterThan(0.0));
      expect(result.baselineFp32!.latencyMs.mean, greaterThan(0.0));
      expect(result.quantizedInt8!.latencyMs.mean, greaterThan(0.0));
      expect(progressValues.isNotEmpty, isTrue);

      await sub.cancel();
    });

    test('BenchmarkNotifier triggers run and updates BenchmarkState', () async {
      final container = ProviderContainer(
        overrides: [
          benchmarkServiceProvider.overrideWithValue(benchmarkService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(benchmarkStateProvider.notifier);
      expect(container.read(benchmarkStateProvider).isRunning, isFalse);

      await notifier.executeBenchmark(runs: 3, warmupRuns: 1);

      final state = container.read(benchmarkStateProvider);
      expect(state.isRunning, isFalse);
      expect(state.result, isNotNull);
      expect(state.result!.speedupMultiplier, greaterThan(1.0));
    });
  });
}

