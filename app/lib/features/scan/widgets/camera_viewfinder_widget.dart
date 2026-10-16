import 'package:flutter/material.dart';

/// Camera / Probe Viewfinder widget reproducing the scan2.png camera frame.
class CameraViewfinderWidget extends StatelessWidget {
  final String guidanceText;
  final bool isProbeActive;

  const CameraViewfinderWidget({
    super.key,
    this.guidanceText = 'Face the light, remove glasses',
    this.isProbeActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8), // Neutral camera viewport grey
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Center Skin/Face Target Illustration
          _buildCenterIllustration(),

          // 2. Center White Oval Guide matching scan2.png
          Container(
            width: 200,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
              borderRadius: const BorderRadius.all(Radius.elliptical(100, 130)),
            ),
          ),

          // 3. Four Corner Brackets matching scan2.png
          Positioned(
            left: 45,
            top: 55,
            child: _buildCornerBracket(isTop: true, isLeft: true),
          ),
          Positioned(
            right: 45,
            top: 55,
            child: _buildCornerBracket(isTop: true, isLeft: false),
          ),
          Positioned(
            left: 45,
            bottom: 55,
            child: _buildCornerBracket(isTop: false, isLeft: true),
          ),
          Positioned(
            right: 45,
            bottom: 55,
            child: _buildCornerBracket(isTop: false, isLeft: false),
          ),

          // 4. Floating Guidance Pill at Top Center
          Positioned(
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 17,
                    color: Color(0xFF0F172A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    guidanceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIllustration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stylized face avatar
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFD6A284), // Warm skin tone base
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hair shape
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF334155),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(70)),
                  ),
                ),
              ),
              // Eyes and features
              Positioned(
                top: 65,
                left: 36,
                right: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 12, height: 6, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(3))),
                    Container(width: 12, height: 6, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(3))),
                  ],
                ),
              ),
              // Gentle smile
              Positioned(
                bottom: 35,
                child: Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D5B4C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    const double size = 28.0;
    const double thickness = 3.5;
    const color = Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Horizontal line
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: size,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Vertical line
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
