import 'package:flutter/material.dart';
import '../../shared/owner_placeholder_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FairScope Scan'),
      ),
      body: const OwnerPlaceholderCard(
        title: 'Camera & Condition Scan',
        owner: 'Member A',
        role: 'AI: Image Branch & Rare-Class Detection',
        description:
            'Camera capture, real-time image normalization, and skin condition classification with rare-class accuracy indicators.',
        icon: Icons.camera_alt_outlined,
        badgeText: 'Member A • In progress',
      ),
    );
  }
}

