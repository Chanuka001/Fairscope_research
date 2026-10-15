import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model_runner_service.dart';
import 'tflite_model_runner_service.dart';

/// Riverpod provider for on-device ModelRunnerService
final modelRunnerProvider = Provider<ModelRunnerService>((ref) {
  final service = TfliteModelRunnerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
