import 'package:flutter/material.dart';
import '../../shared/owner_placeholder_card.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Comparison'),
      ),
      body: const OwnerPlaceholderCard(
        title: 'Original vs Compressed Benchmark',
        owner: 'Member C (Monal)',
        role: 'Deploy: Compression & On-Phone Optimization',
        description:
            'Benchmarking float32 baseline vs int8 quantized TFLite models on device. Real-time latency (ms), model size reduction, and speedup profiling.',
        icon: Icons.bar_chart_rounded,
        badgeText: 'Member C • Active Focus',
      ),
    );
  }
}
