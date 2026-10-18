import 'package:flutter/foundation.dart';

/// Statistical latency distribution in milliseconds for benchmark runs.
@immutable
class BenchmarkLatency {
  final double mean;
  final double median;
  final double min;
  final double max;
  final double std;

  const BenchmarkLatency({
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.std,
  });

  factory BenchmarkLatency.fromJson(Map<String, dynamic> json) {
    return BenchmarkLatency(
      mean: (json['mean'] as num).toDouble(),
      median: (json['median'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      std: (json['std'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mean': mean,
      'median': median,
      'min': min,
      'max': max,
      'std': std,
    };
  }

  @override
  String toString() =>
      'BenchmarkLatency(mean: ${mean.toStringAsFixed(2)}ms, median: ${median.toStringAsFixed(2)}ms, min: ${min.toStringAsFixed(2)}ms, max: ${max.toStringAsFixed(2)}ms, std: ${std.toStringAsFixed(2)})';
}

/// Evaluation metrics for a specific model variant (e.g. baseline_fp32 or quantized_int8).
@immutable
class BenchmarkVariant {
  final String name;
  final double sizeMb;
  final BenchmarkLatency latencyMs;
  final double? peakRamMb;
  final double? accuracyOverall;
  final double? accuracyRare;

  const BenchmarkVariant({
    required this.name,
    required this.sizeMb,
    required this.latencyMs,
    this.peakRamMb,
    this.accuracyOverall,
    this.accuracyRare,
  });

  factory BenchmarkVariant.fromJson(Map<String, dynamic> json) {
    return BenchmarkVariant(
      name: json['name'] as String,
      sizeMb: (json['size_mb'] as num).toDouble(),
      latencyMs: BenchmarkLatency.fromJson(
        json['latency_ms'] as Map<String, dynamic>,
      ),
      peakRamMb: (json['peak_ram_mb'] as num?)?.toDouble(),
      accuracyOverall: (json['accuracy_overall'] as num?)?.toDouble(),
      accuracyRare: (json['accuracy_rare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size_mb': sizeMb,
      'latency_ms': latencyMs.toJson(),
      'peak_ram_mb': peakRamMb,
      'accuracy_overall': accuracyOverall,
      'accuracy_rare': accuracyRare,
    };
  }

  @override
  String toString() =>
      'BenchmarkVariant($name, size: ${sizeMb.toStringAsFixed(2)}MB, latency: ${latencyMs.mean.toStringAsFixed(2)}ms)';
}

/// Pipeline timing statistics (transfer, preprocessing, total pipeline).
@immutable
class PipelineTiming {
  final double? transferMean;
  final double preprocessMean;
  final double? totalMean;

  const PipelineTiming({
    this.transferMean,
    required this.preprocessMean,
    this.totalMean,
  });

  factory PipelineTiming.fromJson(Map<String, dynamic> json) {
    return PipelineTiming(
      transferMean: (json['transfer_mean'] as num?)?.toDouble(),
      preprocessMean: (json['preprocess_mean'] as num).toDouble(),
      totalMean: (json['total_mean'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transfer_mean': transferMean,
      'preprocess_mean': preprocessMean,
      'total_mean': totalMean,
    };
  }

  @override
  String toString() =>
      'PipelineTiming(transfer: $transferMean ms, preprocess: $preprocessMean ms, total: $totalMean ms)';
}

/// Comprehensive benchmark report matching Section 8 of the research spec.
@immutable
class BenchmarkResult {
  final String device;
  final String androidVersion;
  final String date;
  final String modelVersion;
  final String probe;
  final int runs;
  final int warmupRuns;
  final PipelineTiming pipelineMs;
  final List<BenchmarkVariant> variants;

  const BenchmarkResult({
    required this.device,
    required this.androidVersion,
    required this.date,
    required this.modelVersion,
    required this.probe,
    required this.runs,
    required this.warmupRuns,
    required this.pipelineMs,
    required this.variants,
  });

  /// Finds variant by name (e.g., 'baseline_fp32' or 'quantized_int8').
  BenchmarkVariant? getVariant(String name) {
    for (final v in variants) {
      if (v.name == name) return v;
    }
    return null;
  }

  /// Baseline FP32 variant if present.
  BenchmarkVariant? get baselineFp32 => getVariant('baseline_fp32');

  /// Quantized INT8 variant if present.
  BenchmarkVariant? get quantizedInt8 => getVariant('quantized_int8');

  /// Computes latency speedup ratio (FP32 mean latency / INT8 mean latency).
  double? get speedupMultiplier {
    final fp32 = baselineFp32;
    final int8 = quantizedInt8;
    if (fp32 == null || int8 == null || int8.latencyMs.mean <= 0) return null;
    return fp32.latencyMs.mean / int8.latencyMs.mean;
  }

  /// Computes model size reduction percentage ((FP32 size - INT8 size) / FP32 size * 100).
  double? get sizeReductionPercent {
    final fp32 = baselineFp32;
    final int8 = quantizedInt8;
    if (fp32 == null || int8 == null || fp32.sizeMb <= 0) return null;
    return ((fp32.sizeMb - int8.sizeMb) / fp32.sizeMb) * 100.0;
  }

  factory BenchmarkResult.fromJson(Map<String, dynamic> json) {
    return BenchmarkResult(
      device: json['device'] as String,
      androidVersion: json['android_version'] as String,
      date: json['date'] as String,
      modelVersion: json['model_version'] as String,
      probe: json['probe'] as String,
      runs: (json['runs'] as num).toInt(),
      warmupRuns: (json['warmup_runs'] as num).toInt(),
      pipelineMs: PipelineTiming.fromJson(
        json['pipeline_ms'] as Map<String, dynamic>,
      ),
      variants: (json['variants'] as List<dynamic>)
          .map((item) => BenchmarkVariant.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'android_version': androidVersion,
      'date': date,
      'model_version': modelVersion,
      'probe': probe,
      'runs': runs,
      'warmup_runs': warmupRuns,
      'pipeline_ms': pipelineMs.toJson(),
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

