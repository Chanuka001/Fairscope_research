/// Represents the on-device model variants per Section 5 of app spec.
enum ModelVariant {
  baselineFp32('Original (float32)', 'assets/models/baseline_fp32.tflite'),
  quantizedInt8('Compressed (int8)', 'assets/models/quantized_int8.tflite');

  final String displayName;
  final String assetPath;

  const ModelVariant(this.displayName, this.assetPath);
}

