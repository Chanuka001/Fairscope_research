import 'package:flutter/material.dart';

/// Spacing, dimensions, radii, and shadows from docs/designs/Design Tokens.png
class AppSpacing {
  AppSpacing._();

  // Spacing Scale
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;

  // Screen Padding
  static const double screenPadding = 16.0;
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(16.0);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);

  // Card Padding
  static const double cardPadding = 16.0;
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(16.0);

  // Component Sizes
  static const double buttonHeight = 48.0;
  static const double chipHeight = 32.0;
  static const double bottomNavHeight = 64.0;
  static const double topBarHeight = 56.0;
  static const double stepIndicatorLine = 8.0;
  static const double stepIndicatorDots = 4.0;

  // Icon Sizes
  static const double iconLarge = 24.0;
  static const double iconMedium = 20.0;
  static const double iconSmall = 16.0;

  // Progress & Controls
  static const double progressRingOuter = 56.0;
  static const double progressRingInner = 48.0;
  static const double progressBarHeight = 8.0;
  static const double sliderTrackHeight = 4.0;
  static const double sliderThumbSize = 24.0;
}

/// Shape / Corner Radii tokens from docs/designs/Design Tokens.png
class AppRadii {
  AppRadii._();

  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;

  static const Radius rExtraSmall = Radius.circular(extraSmall);
  static const Radius rSmall = Radius.circular(small);
  static const Radius rMedium = Radius.circular(medium);
  static const Radius rLarge = Radius.circular(large);
  static const Radius rExtraLarge = Radius.circular(extraLarge);

  static const BorderRadius brExtraSmall = BorderRadius.all(rExtraSmall);
  static const BorderRadius brSmall = BorderRadius.all(rSmall);
  static const BorderRadius brMedium = BorderRadius.all(rMedium);
  static const BorderRadius brLarge = BorderRadius.all(rLarge);
  static const BorderRadius brExtraLarge = BorderRadius.all(rExtraLarge);
}

/// Elevation & Shadow tokens from docs/designs/Design Tokens.png
class AppShadows {
  AppShadows._();

  static const Color shadowColor = Color(0x1A000000); // #0000001A

  // Level 0: flat
  static const List<BoxShadow> level0 = [];

  // Level 1: soft card shadow
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0D0F172A), // 5% slate
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  // Level 2: medium elevated shadow
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x140F172A), // 8% slate
      offset: Offset(0, 4),
      blurRadius: 16.0,
      spreadRadius: 0,
    ),
  ];

  // Level 3: high elevation
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1F0F172A), // 12% slate
      offset: Offset(0, 8),
      blurRadius: 24.0,
      spreadRadius: 0,
    ),
  ];
}

