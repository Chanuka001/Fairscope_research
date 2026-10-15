/// Statistics for timed benchmark runs
class LatencyStats {
  final double mean;
  final double median;
  final double min;
  final double max;
  final double std;

  const LatencyStats({
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.std,
  });

  Map<String, dynamic> toJson() {
    return {
      'mean': mean,
      'median': median,
      'min': min,
      'max': max,
      'std': std,
    };
  }

  factory LatencyStats.fromJson(Map<String, dynamic> json) {
    return LatencyStats(
      mean: (json['mean'] as num).toDouble(),
      median: (json['median'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      std: (json['std'] as num).toDouble(),
    );
  }
}

/// Benchmark metrics for a single model variant (fp32 or int8)
class ModelVariantBenchmark {
  final String name;
  final double sizeMb;
  final LatencyStats latencyMs;
  final double preprocessMsMean;
  final double? peakRamMb;
  final double? accuracyOverall;
  final double? accuracyRare;

  const ModelVariantBenchmark({
    required this.name,
    required this.sizeMb,
    required this.latencyMs,
    required this.preprocessMsMean,
    this.peakRamMb,
    this.accuracyOverall,
    this.accuracyRare,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size_mb': sizeMb,
      'latency_ms': latencyMs.toJson(),
      'preprocess_ms_mean': preprocessMsMean,
      'peak_ram_mb': peakRamMb,
      'accuracy_overall': accuracyOverall,
      'accuracy_rare': accuracyRare,
    };
  }

  factory ModelVariantBenchmark.fromJson(Map<String, dynamic> json) {
    return ModelVariantBenchmark(
      name: json['name'] as String,
      sizeMb: (json['size_mb'] as num).toDouble(),
      latencyMs: LatencyStats.fromJson(json['latency_ms'] as Map<String, dynamic>),
      preprocessMsMean: (json['preprocess_ms_mean'] as num).toDouble(),
      peakRamMb: (json['peak_ram_mb'] as num?)?.toDouble(),
      accuracyOverall: (json['accuracy_overall'] as num?)?.toDouble(),
      accuracyRare: (json['accuracy_rare'] as num?)?.toDouble(),
    );
  }
}

/// Standardized benchmark report matching Section 6 of app/README.MD
class BenchmarkReport {
  final String device;
  final String androidVersion;
  final String date;
  final String modelVersion;
  final int runs;
  final int warmupRuns;
  final List<ModelVariantBenchmark> variants;

  const BenchmarkReport({
    required this.device,
    required this.androidVersion,
    required this.date,
    required this.modelVersion,
    required this.runs,
    required this.warmupRuns,
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'android_version': androidVersion,
      'date': date,
      'model_version': modelVersion,
      'runs': runs,
      'warmup_runs': warmupRuns,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  factory BenchmarkReport.fromJson(Map<String, dynamic> json) {
    return BenchmarkReport(
      device: json['device'] as String,
      androidVersion: json['android_version'] as String,
      date: json['date'] as String,
      modelVersion: json['model_version'] as String,
      runs: json['runs'] as int,
      warmupRuns: json['warmup_runs'] as int,
      variants: (json['variants'] as List<dynamic>)
          .map((e) => ModelVariantBenchmark.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

