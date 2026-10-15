import 'model_variant.dart';

/// Data class representing on-device inference predictions.
/// Labeled 'analysis result' rather than diagnostic conclusion.
class Prediction {
  final String label;
  final double confidence;
  final ModelVariant variant;
  final Duration inferenceLatency;
  final DateTime timestamp;
  final Map<String, double> allProbabilities;
  final bool isPlaceholderModel;

  const Prediction({
    required this.label,
    required this.confidence,
    required this.variant,
    required this.inferenceLatency,
    required this.timestamp,
    this.allProbabilities = const {},
    this.isPlaceholderModel = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'variant': variant.name,
      'latency_ms': inferenceLatency.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'all_probabilities': allProbabilities,
      'is_placeholder_model': isPlaceholderModel,
    };
  }

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      variant: ModelVariant.values.firstWhere(
        (v) => v.name == json['variant'],
        orElse: () => ModelVariant.baselineFp32,
      ),
      inferenceLatency: Duration(milliseconds: json['latency_ms'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      allProbabilities: (json['all_probabilities'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
      isPlaceholderModel: json['is_placeholder_model'] as bool? ?? true,
    );
  }
}

