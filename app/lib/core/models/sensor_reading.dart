/// Data model representing telemetric physical skin readings from the IoT probe.
/// Owned by Member B contract.
class SensorReading {
  final DateTime timestamp;
  final double moisturePercent;
  final double skinTemperature;
  final int colorIndex;
  final bool isConnected;

  const SensorReading({
    required this.timestamp,
    required this.moisturePercent,
    required this.skinTemperature,
    required this.colorIndex,
    this.isConnected = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'moisture_percent': moisturePercent,
      'skin_temperature': skinTemperature,
      'color_index': colorIndex,
      'is_connected': isConnected,
    };
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      moisturePercent: (json['moisture_percent'] as num).toDouble(),
      skinTemperature: (json['skin_temperature'] as num).toDouble(),
      colorIndex: json['color_index'] as int,
      isConnected: json['is_connected'] as bool? ?? true,
    );
  }

  SensorReading copyWith({
    DateTime? timestamp,
    double? moisturePercent,
    double? skinTemperature,
    int? colorIndex,
    bool? isConnected,
  }) {
    return SensorReading(
      timestamp: timestamp ?? this.timestamp,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      skinTemperature: skinTemperature ?? this.skinTemperature,
      colorIndex: colorIndex ?? this.colorIndex,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

