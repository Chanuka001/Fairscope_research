import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography design tokens extracted from docs/designs/Design Tokens.png
/// Font family: Inter (system sans-serif fallback)
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // Display: Size 32, Bold (w700), Line Height 40 (40/32 = 1.25)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 40.0 / 32.0,
    color: AppColors.text,
  );

  // Headline: Size 24, Semibold (w600), Line Height 32 (32/24 = 1.33)
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 32.0 / 24.0,
    color: AppColors.text,
  );

  // Title: Size 20, Semibold (w600), Line Height 28 (28/20 = 1.40)
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 28.0 / 20.0,
    color: AppColors.text,
  );

  // Body Large: Size 18, Medium (w500), Line Height 26 (26/18 = 1.44)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    height: 26.0 / 18.0,
    color: AppColors.text,
  );

  // Body: Size 16, Regular (w400), Line Height 24 (24/16 = 1.50)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 24.0 / 16.0,
    color: AppColors.text,
  );

  // Label: Size 14, Medium (w500), Line Height 20 (20/14 = 1.43)
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 14.0,
    color: AppColors.text,
  );

  // Caption: Size 12, Regular (w400), Line Height 16 (16/12 = 1.33)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 16.0 / 12.0,
    color: AppColors.secondaryText,
  );
}

