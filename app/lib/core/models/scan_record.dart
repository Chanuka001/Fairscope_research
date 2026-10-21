import 'package:flutter/foundation.dart';
import 'capture.dart';
import 'prediction.dart';

/// Persisted record of an analysed multimodal scan stored in private app storage.
///
/// In accordance with privacy and research rules:
/// - Only analysed captures are stored in History.
/// - Unanalysed captures are discarded when memory is cleared.
/// - Records are stored strictly in private device storage with no cloud sync.
@immutable
class ScanRecord {
  /// Unique identifier formatted as `FS-xxxx` (e.g., "FS-0001").
  final String id;

  /// Optional anonymized label entered by the user (e.g., "Scan #1 - Forehead").
  /// Reminder: Never contain personal identifying information or real names.
  final String? label;

  /// Associated multimodal capture data (JPEG bytes and sensor reading).
  final Capture capture;

  /// On-device model prediction output.
  final Prediction prediction;

  /// Measured pipeline execution timings in milliseconds.
  /// Standard keys: "inference_ms", "preprocess_ms", "transfer_ms", "total_ms".
  final Map<String, double> timings;

  /// Name of the TFLite model variant used (e.g. "baseline_fp32", "quantized_int8").
  final String modelVariant;

  /// Creation timestamp when the scan was analysed and committed to History.
  final DateTime createdAt;

  const ScanRecord({
    required this.id,
    this.label,
    required this.capture,
    required this.prediction,
    required this.timings,
    required this.modelVariant,
    required this.createdAt,
  });

  /// Total pipeline duration in milliseconds (if available).
  double? get totalDurationMs => timings['total_ms'];

  /// Inference duration in milliseconds.
  double? get inferenceMs => timings['inference_ms'];

  /// Preprocessing duration in milliseconds.
  double? get preprocessMs => timings['preprocess_ms'];

  /// Creates a [ScanRecord] from JSON map.
  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as String,
      label: json['label'] as String?,
      capture: Capture.fromJson(json['capture'] as Map<String, dynamic>),
      prediction: Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
      timings: (json['timings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      modelVariant: json['model_variant'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this record to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (label != null) 'label': label,
      'capture': capture.toJson(),
      'prediction': prediction.toJson(),
      'timings': timings,
      'model_variant': modelVariant,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with optionally modified values.
  ScanRecord copyWith({
    String? id,
    String? label,
    Capture? capture,
    Prediction? prediction,
    Map<String, double>? timings,
    String? modelVariant,
    DateTime? createdAt,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      label: label ?? this.label,
      capture: capture ?? this.capture,
      prediction: prediction ?? this.prediction,
      timings: timings ?? this.timings,
      modelVariant: modelVariant ?? this.modelVariant,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          modelVariant == other.modelVariant &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^ label.hashCode ^ modelVariant.hashCode ^ createdAt.hashCode;

  @override
  String toString() =>
      'ScanRecord(id: $id, label: $label, variant: $modelVariant, date: $createdAt)';
}

