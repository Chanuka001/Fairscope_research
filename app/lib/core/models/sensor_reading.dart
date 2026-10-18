import 'package:flutter/foundation.dart';

/// Sensor reading captured by the wireless ESP32 probe hardware.
///
/// Contains skin bio-sensing readings (moisture, temperature, color index)
/// alongside the capture timestamp.
@immutable
class SensorReading {
  /// Skin moisture percentage / reading level (0.0 to 100.0).
  final double moisture;

  /// Surface skin temperature in Celsius.
  final double temperature;

  /// Color index representation from probe sensor.
  final int colorIndex;

  /// Timestamp when the sensor reading was taken.
  final DateTime timestamp;

  const SensorReading({
    required this.moisture,
    required this.temperature,
    required this.colorIndex,
    required this.timestamp,
  });

  /// Creates a [SensorReading] from JSON map.
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      moisture: (json['moisture'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      colorIndex: (json['color_index'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this reading to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'temperature': temperature,
      'color_index': colorIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy with optionally modified values.
  SensorReading copyWith({
    double? moisture,
    double? temperature,
    int? colorIndex,
    DateTime? timestamp,
  }) {
    return SensorReading(
      moisture: moisture ?? this.moisture,
      temperature: temperature ?? this.temperature,
      colorIndex: colorIndex ?? this.colorIndex,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorReading &&
          runtimeType == other.runtimeType &&
          moisture == other.moisture &&
          temperature == other.temperature &&
          colorIndex == other.colorIndex &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      moisture.hashCode ^
      temperature.hashCode ^
      colorIndex.hashCode ^
      timestamp.hashCode;

  @override
  String toString() =>
      'SensorReading(moisture: $moisture, temp: $temperature°C, colorIndex: $colorIndex, time: $timestamp)';
}

