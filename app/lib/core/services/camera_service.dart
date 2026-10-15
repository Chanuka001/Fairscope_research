/// Abstract service interface for camera image capture and preprocessing.
/// Interface owned by Member C + A; camera capture screen owned by Member A.
abstract class CameraService {
  /// Initializes the device camera controller.
  Future<void> initialize();

  /// Captures a photo and returns the local file path on disk.
  Future<String> capturePhoto();

  /// Preprocesses an image file into the normalized 3D tensor expected by TFLite.
  Future<List<List<List<double>>>> preprocessImage(String filePath);

  /// Disposes camera resources.
  void dispose();
}

