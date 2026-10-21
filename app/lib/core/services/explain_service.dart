import 'dart:typed_data';
import '../models/prediction.dart';

/// Abstract service for explainability and Grad-CAM visualizations.
///
/// Note: Real explainability model and fairness analytics are owned by Member D.
/// This contract provides the clean abstraction required by the app shell.
abstract class ExplainService {
  /// Generates or fetches a visual heatmap overlay for the given image and prediction.
  Future<Uint8List> generateHeatmapOverlay(
    Uint8List sourceImageBytes,
    Prediction prediction,
  );

  /// Provides a plain-language explanation of the model's focus regions.
  Future<String> getExplanationText(Prediction prediction);
}

