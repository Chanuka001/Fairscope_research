import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/sensor_reading.dart';
import '../../core/services/sensor_providers.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/sparkline_widget.dart';

/// Sensor Screen displaying real-time probe telemetry matching sensor3.png.
/// Owned by Member B: IoT: Sensor Probe Hardware.
class SensorScreen extends ConsumerStatefulWidget {
  const SensorScreen({super.key});

  @override
  ConsumerState<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends ConsumerState<SensorScreen> {
  // Recent history buffers for sparklines
  final List<double> _moistureHistory = [40.0, 41.2, 40.8, 41.5, 42.0, 42.4, 41.8, 42.0];
  final List<double> _tempHistory = [32.1, 32.2, 32.3, 32.2, 32.4, 32.5, 32.4, 32.4];
  final List<double> _colorHistory = [125.0, 126.0, 127.0, 126.0, 128.0, 129.0, 127.0, 128.0];

  bool _isConnecting = false;

  void _updateHistory(SensorReading reading) {
    if (!reading.isConnected) return;
    setState(() {
      _moistureHistory.add(reading.moisturePercent);
      if (_moistureHistory.length > 20) _moistureHistory.removeAt(0);

      _tempHistory.add(reading.skinTemperature);
      if (_tempHistory.length > 20) _tempHistory.removeAt(0);

      _colorHistory.add(reading.colorIndex.toDouble());
      if (_colorHistory.length > 20) _colorHistory.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorService = ref.watch(sensorServiceProvider);
    final readingAsync = ref.watch(sensorReadingStreamProvider);

    // Listen to incoming stream without rebuilding the entire scaffold
    ref.listen<AsyncValue<SensorReading>>(sensorReadingStreamProvider, (prev, next) {
      next.whenData(_updateHistory);
    });

    final currentReading = readingAsync.asData?.value ??
        sensorService.currentReading ??
        SensorReading(
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          moisturePercent: 42.0,
          skinTemperature: 32.4,
          colorIndex: 128,
          isConnected: true,
        );

    final isConnected = sensorService.isConnected;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sensor'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Mock Data Info Banner per Section 7
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.heatmapLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Using mock data',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Member B: IoT Sensor Probe (Hardware in development)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. FairScope Probe Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Probe Icon Avatar
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sensors_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Name and Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FairScope Probe',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isConnected ? AppColors.success : AppColors.disabledText,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isConnected ? 'Connected' : 'Disconnected',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isConnected ? AppColors.success : AppColors.disabledText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Signal Icon
                          Icon(
                            Icons.signal_cellular_alt_rounded,
                            color: isConnected ? AppColors.success : AppColors.disabledText,
                            size: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Connect / Disconnect button
                      OutlinedButton(
                        onPressed: _isConnecting
                            ? null
                            : () async {
                                setState(() => _isConnecting = true);
                                if (isConnected) {
                                  await sensorService.disconnect();
                                } else {
                                  await sensorService.connect();
                                }
                                setState(() => _isConnecting = false);
                              },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          isConnected ? 'Disconnect' : 'Connect',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Telemetry Metric Cards
              _buildMetricCard(
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.secondary,
                label: 'Moisture',
                value: isConnected ? '${currentReading.moisturePercent.toStringAsFixed(0)}%' : '--',
                lineColor: AppColors.success,
                dataPoints: _moistureHistory,
              ),
              const SizedBox(height: 12),

              _buildMetricCard(
                icon: Icons.thermostat_rounded,
                iconColor: AppColors.secondary,
                label: 'Skin temperature',
                value: isConnected ? '${currentReading.skinTemperature.toStringAsFixed(1)}°C' : '--',
                lineColor: AppColors.secondary,
                dataPoints: _tempHistory,
              ),
              const SizedBox(height: 12),

              _buildMetricCard(
                icon: Icons.palette_rounded,
                iconColor: AppColors.chartSeries3,
                label: 'Color index',
                value: isConnected ? '${currentReading.colorIndex}' : '--',
                lineColor: AppColors.chartSeries3,
                dataPoints: _colorHistory,
              ),
              const SizedBox(height: 16),

              // 4. Bottom Data Rate Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.success : AppColors.disabledText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isConnected ? 'Receiving data, 1 reading/sec' : 'Probe idle (Disconnected)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color lineColor,
    required List<double> dataPoints,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SparklineWidget(
                    dataPoints: dataPoints,
                    lineColor: lineColor,
                    height: 38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
