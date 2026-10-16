import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/benchmark_result.dart';
import 'results_repository.dart';

/// Local storage repository for persisting and loading benchmark and fairness results.
/// Owned by Member C (Monal).
class LocalResultsRepository implements ResultsRepository {
  static const String _benchmarkFileName = 'latest_benchmark.json';

  @override
  Future<BenchmarkReport?> loadLatestBenchmark() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_benchmarkFileName');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return BenchmarkReport.fromJson(data);
      }
    } catch (_) {
      // Local file unavailable, fallback to bundled sample
    }

    try {
      final assetString = await rootBundle.loadString('assets/sample_results/benchmark_report.json');
      final Map<String, dynamic> data = jsonDecode(assetString);
      return BenchmarkReport.fromJson(data);
    } catch (_) {
      return BenchmarkReport.sample;
    }
  }

  @override
  Future<void> saveBenchmarkReport(BenchmarkReport report) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_benchmarkFileName');
      final jsonString = const JsonEncoder.withIndent('  ').convert(report.toJson());
      await file.writeAsString(jsonString);
    } catch (_) {
      // Ignore write failures in read-only environments
    }
  }

  @override
  Future<Map<String, dynamic>> loadFairnessResults() async {
    try {
      final assetString = await rootBundle.loadString('assets/sample_results/fairness_audit.json');
      return jsonDecode(assetString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
