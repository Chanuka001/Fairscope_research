import 'package:flutter/material.dart';

/// Design tokens extracted directly from docs/designs/Design Tokens.png
class AppColors {
  AppColors._();

  // 1. Primary & Accents
  static const Color primary = Color(0xFF0F766E); // Primary Teal 700
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCCF4E9); // Light Mint
  static const Color onPrimaryContainer = Color(0xFF063D37);
  static const Color secondary = Color(0xFF38BDF8); // Accent Sky Blue
  static const Color onSecondary = Color(0xFF0F172A);

  // Surfaces & Background
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color text = Color(0xFF0F172A); // Slate 900
  static const Color secondaryText = Color(0xFF64748B); // Slate 500
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Status & Feedback
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Sensor Pill Colors (from UI Showcase)
  static const Color sensorMoistureBg = Color(0xFFF0F9FF);
  static const Color sensorMoistureIcon = Color(0xFF0284C7);
  static const Color sensorTempBg = Color(0xFFFFFBEB);
  static const Color sensorTempIcon = Color(0xFFD97706);
  static const Color sensorColorBg = Color(0xFFFAF5FF);
  static const Color sensorColorIcon = Color(0xFF7C3AED);

  // Action Button Colors
  static const Color actionEyeBg = Color(0xFFF0FDFA);
  static const Color actionEyeBorder = Color(0xFF99F6E4);
  static const Color actionDeleteBg = Color(0xFFFEF2F2);
  static const Color actionDeleteBorder = Color(0xFFFECACA);

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
