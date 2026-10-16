import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Card displaying summary metrics for one model variant matching compare4.png.
class VariantSummaryCard extends StatelessWidget {
  final String title;
  final Color headerColor;
  final Color headerTextColor;
  final String sizeMb;
  final String latencyMs;
  final int runs;
  final String badgeText;
  final IconData badgeIcon;

  const VariantSummaryCard({
    super.key,
    required this.title,
    required this.headerColor,
    required this.headerTextColor,
    required this.sizeMb,
    required this.latencyMs,
    required this.runs,
    required this.badgeText,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Container Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD).withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              Container(
                color: headerColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model size',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sizeMb MB',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Avg. latency',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$latencyMs ms',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Runs',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$runs',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Bottom Pill Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E), // Deep Teal matching image
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(badgeIcon, color: Colors.white, size: 17),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  badgeText,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

