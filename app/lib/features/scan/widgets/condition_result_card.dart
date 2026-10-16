import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Condition prediction card with direct navigation link to Explain screen.
class ConditionResultCard extends StatelessWidget {
  final String condition;
  final double confidence;
  final VoidCallback onViewExplanation;

  const ConditionResultCard({
    super.key,
    required this.condition,
    required this.confidence,
    required this.onViewExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final int confidencePercent = (confidence * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thumbnail Avatar
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6A284),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Avatar hair
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 28,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF334155),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                      ),
                    ),
                    // Avatar eyes
                    Positioned(
                      top: 32,
                      child: Row(
                        children: [
                          Container(width: 5, height: 3, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 14),
                          Container(width: 5, height: 3, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(2))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 2. Condition & Confidence Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted condition',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Confidence Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: confidence,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$confidencePercent%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Placeholder Model Badge & Connected Explain Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Placeholder badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                ),
                child: const Text(
                  'Placeholder model',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),

              // Direct link to Explain Screen
              ElevatedButton.icon(
                onPressed: onViewExplanation,
                icon: const Icon(Icons.lightbulb_rounded, size: 16),
                label: const Text(
                  'Explain result ➔',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF0F766E),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFF99F6E4), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
