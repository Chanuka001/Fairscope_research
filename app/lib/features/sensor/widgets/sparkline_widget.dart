import 'package:flutter/material.dart';

/// Lightweight custom painter drawing smooth trend lines as shown in sensor3.png
class SparklineWidget extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final double height;

  const SparklineWidget({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          dataPoints: dataPoints,
          lineColor: lineColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _SparklinePainter({
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (dataPoints.length - 1);

    double getY(double val) {
      final normalized = (val - minVal) / range;
      // Invert Y so highest value is near the top
      return size.height - (normalized * (size.height - 10) + 5);
    }

    path.moveTo(0, getY(dataPoints[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(dataPoints[0]));

    for (int i = 0; i < dataPoints.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = getY(dataPoints[i]);
      final x2 = (i + 1) * stepX;
      final y2 = getY(dataPoints[i + 1]);

      final cx = (x1 + x2) / 2;
      path.cubicTo(cx, y1, cx, y2, x2, y2);
      fillPath.cubicTo(cx, y1, cx, y2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill with soft gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw curve line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw endpoint dot
    final lastX = size.width;
    final lastY = getY(dataPoints.last);
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lastX, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.lineColor != lineColor;
  }
}
