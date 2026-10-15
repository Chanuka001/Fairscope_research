import '../models/prediction.dart';

/// Abstract service interface for explainability and fairness overlays.
/// Owned by Member D.
abstract class ExplainService {
  /// Generates or loads a Grad-CAM saliency heatmap overlay for an image.
  Future<String> generateGradCamOverlay({
    required String imagePath,
    required Prediction prediction,
  });

  /// Loads accuracy disparity data grouped by Fitzpatrick skin types (I through VI).
  Future<Map<String, dynamic>> getSkinToneFairnessData();
}
