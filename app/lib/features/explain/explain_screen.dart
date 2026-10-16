import 'package:flutter/material.dart';
import '../../shared/owner_placeholder_card.dart';

class ExplainScreen extends StatelessWidget {
  const ExplainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: OwnerPlaceholderCard(
          title: 'Grad-CAM & Fairness Analysis',
          owner: 'Member D',
          role: 'AI: Explainability & Cross-Population Fairness',
          description:
              'Visual saliency heatmaps via Grad-CAM, feature attribution, and fairness disparity analysis across Fitzpatrick skin types I through VI.',
          icon: Icons.lightbulb_outline_rounded,
          badgeText: 'Member D • In progress',
        ),
      ),
    );
  }
}

