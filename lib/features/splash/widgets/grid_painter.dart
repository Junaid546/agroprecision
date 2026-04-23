import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSpacing;
  final double strokeWidth;

  GridPainter({
    this.gridColor = const Color(0xFF000000),
    this.gridSpacing = 32.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
