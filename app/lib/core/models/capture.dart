import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'sensor_reading.dart';

/// A multimodal capture packet received from the ESP32-CAM probe.
///
/// Contains the raw JPEG image bytes captured by the OV2640 sensor,
/// associated [SensorReading] skin data, transmission latency, and reception timestamp.
@immutable
class Capture {
  /// Unique temporary identifier for the capture (e.g. "CAP-1718900000").
  final String id;

  /// Raw JPEG bytes transferred from probe camera.
  final Uint8List imageBytes;

  /// Multimodal sensor readings gathered at the moment of capture.
  final SensorReading sensorReading;

  /// Local device timestamp when the full packet was received.
  final DateTime receivedTime;

  /// Wireless transfer duration in milliseconds (if measured).
  final int? transferMs;

  const Capture({
    required this.id,
    required this.imageBytes,
    required this.sensorReading,
    required this.receivedTime,
    this.transferMs,
  });

  /// Size of the raw JPEG image in bytes.
  int get imageSizeBytes => imageBytes.lengthInBytes;

  /// Human-readable formatted file size (e.g., "48.2 KB").
  String get formattedImageSize {
    final kb = imageSizeBytes / 1024.0;
    if (kb >= 1024.0) {
      return '${(kb / 1024.0).toStringAsFixed(2)} MB';
    }
    return '${kb.toStringAsFixed(1)} KB';
  }

  /// Creates a [Capture] from JSON map.
  factory Capture.fromJson(Map<String, dynamic> json) {
    return Capture(
      id: json['id'] as String,
      imageBytes: base64Decode(json['image_bytes_base64'] as String),
      sensorReading: SensorReading.fromJson(
        json['sensor_reading'] as Map<String, dynamic>,
      ),
      receivedTime: DateTime.parse(json['received_time'] as String),
      transferMs: json['transfer_ms'] as int?,
    );
  }

  /// Converts this capture to a JSON map with base64 encoded image bytes.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_bytes_base64': base64Encode(imageBytes),
      'sensor_reading': sensorReading.toJson(),
      'received_time': receivedTime.toIso8601String(),
      'transfer_ms': transferMs,
    };
  }

  /// Creates a copy with optionally modified values.
  Capture copyWith({
    String? id,
    Uint8List? imageBytes,
    SensorReading? sensorReading,
    DateTime? receivedTime,
    int? transferMs,
  }) {
    return Capture(
      id: id ?? this.id,
      imageBytes: imageBytes ?? this.imageBytes,
      sensorReading: sensorReading ?? this.sensorReading,
      receivedTime: receivedTime ?? this.receivedTime,
      transferMs: transferMs ?? this.transferMs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Capture &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          receivedTime == other.receivedTime &&
          transferMs == other.transferMs &&
          sensorReading == other.sensorReading;

  @override
  int get hashCode =>
      id.hashCode ^
      receivedTime.hashCode ^
      transferMs.hashCode ^
      sensorReading.hashCode;

  @override
  String toString() =>
      'Capture(id: $id, size: $formattedImageSize, transferMs: ${transferMs ?? "N/A"}ms, time: $receivedTime)';
}

