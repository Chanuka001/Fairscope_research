import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/model_variant.dart';
import '../models/prediction.dart';
import '../models/sensor_reading.dart';

/// Holds the active scan state shared across all 4 screens per Section 2 of app spec.
class CurrentScan {
  final String? imagePath;
  final SensorReading? sensorReading;
  final DateTime? timestamp;
  final Prediction? prediction;
  final ModelVariant modelVariant;

  const CurrentScan({
    this.imagePath,
    this.sensorReading,
    this.timestamp,
    this.prediction,
    this.modelVariant = ModelVariant.baselineFp32,
  });

  CurrentScan copyWith({
    String? imagePath,
    SensorReading? sensorReading,
    DateTime? timestamp,
    Prediction? prediction,
    ModelVariant? modelVariant,
  }) {
    return CurrentScan(
      imagePath: imagePath ?? this.imagePath,
      sensorReading: sensorReading ?? this.sensorReading,
      timestamp: timestamp ?? this.timestamp,
      prediction: prediction ?? this.prediction,
      modelVariant: modelVariant ?? this.modelVariant,
    );
  }
}

/// Riverpod notifier managing the active scan session.
class CurrentScanNotifier extends Notifier<CurrentScan> {
  @override
  CurrentScan build() {
    return const CurrentScan();
  }

  void setImage(String path) {
    state = state.copyWith(imagePath: path, timestamp: DateTime.now());
  }

  void setSensorReading(SensorReading reading) {
    state = state.copyWith(sensorReading: reading);
  }

  void setPrediction(Prediction prediction) {
    state = state.copyWith(
      prediction: prediction,
      modelVariant: prediction.variant,
    );
  }

  void setModelVariant(ModelVariant variant) {
    state = state.copyWith(modelVariant: variant);
  }

  void reset() {
    state = const CurrentScan();
  }
}

final currentScanProvider =
    NotifierProvider<CurrentScanNotifier, CurrentScan>(CurrentScanNotifier.new);

