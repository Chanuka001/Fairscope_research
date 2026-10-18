import 'package:flutter/material.dart';

/// Design tokens extracted directly from docs/designs/Design Tokens.png
class AppColors {
  AppColors._();

  // 1. Primary & Accents
  static const Color primary = Color(0xFF0F766E); // Primary Teal
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCCF4E9);
  static const Color onPrimaryContainer = Color(0xFF063D37);
  static const Color secondary = Color(0xFF38BDF8); // Accent Blue
  static const Color onSecondary = Color(0xFF0F172A);

  // Surfaces & Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color text = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color border = Color(0xFFCBD5E1);

  // Status & Feedback
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Chart Colors
  static const Color chart1 = Color(0xFF38BDF8);
  static const Color chart2 = Color(0xFF0F766E);
  static const Color chart3 = Color(0xFFA78BFA);

  // Heatmap Gradient (low -> high)
  static const Color heatmapLow = Color(0xFFE0F2FE);
  static const Color heatmapHigh = Color(0xFFF59E0B);

  // Disabled States
  static const Color disabledFill = Color(0xFFE2E8F0);
  static const Color disabledText = Color(0xFF94A3B8);
}

