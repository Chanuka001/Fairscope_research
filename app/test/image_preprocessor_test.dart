import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:fairscope_app/core/services/isolate_image_preprocessor.dart';
import 'package:fairscope_app/core/services/image_preprocessor.dart';

void main() {
  group('IsolateImagePreprocessor tests', () {
    late Uint8List testJpegBytes;

    setUpAll(() {
      // Create a synthetic 100x80 image
      final image = img.Image(width: 100, height: 80);
      img.fill(image, color: img.ColorRgb8(200, 100, 50));
      testJpegBytes = Uint8List.fromList(img.encodeJpg(image));
    });

    test('preprocesses to 224x224x3 FP32 tensor in [-1.0, 1.0] range', () async {
      final preprocessor = IsolateImagePreprocessor();
      final tensor = await preprocessor.preprocess(
        testJpegBytes,
        options: const PreprocessOptions(
          targetWidth: 224,
          targetHeight: 224,
          isQuantized: false,
        ),
      );

      expect(tensor is List, isTrue);
      final rows = tensor as List;
      expect(rows.length, 224);
      expect(rows[0].length, 224);
      expect(rows[0][0].length, 3);

      final val = rows[0][0][0] as double;
      expect(val, inInclusiveRange(-1.0, 1.0));
      expect(preprocessor.lastPreprocessDurationMs, isNotNull);
      expect(preprocessor.lastPreprocessDurationMs!, greaterThanOrEqualTo(0.0));
    });

    test('preprocesses to 224x224x3 INT8 quantized tensor in [-128, 127] range', () async {
      final preprocessor = IsolateImagePreprocessor();
      final tensor = await preprocessor.preprocess(
        testJpegBytes,
        options: const PreprocessOptions(
          targetWidth: 224,
          targetHeight: 224,
          isQuantized: true,
        ),
      );

      expect(tensor is List, isTrue);
      final rows = tensor as List;
      expect(rows.length, 224);
      expect(rows[0].length, 224);
      expect(rows[0][0].length, 3);

      final val = rows[0][0][0] as int;
      expect(val, inInclusiveRange(-128, 127));
    });
  });
}

