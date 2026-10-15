import 'package:flutter/material.dart';
import '../../shared/owner_placeholder_card.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Sensor Probe'),
      ),
      body: const OwnerPlaceholderCard(
        title: 'Hardware Sensor Probe',
        owner: 'Member B',
        role: 'IoT: Sensor Probe Hardware & BLE Stream',
        description:
            'Wireless probe pairing via BLE, real-time hydration moisture (%) tracking, skin surface temperature, and multi-wavelength optical color index readings.',
        icon: Icons.sensors_outlined,
        badgeText: 'Member B • In progress',
      ),
    );
  }
}

