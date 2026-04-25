import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum OnboardingIllustration { farmDigitized, offline, smartInsights }

class OnboardingIllustrationWidget extends StatelessWidget {
  final OnboardingIllustration type;
  final double size;

  const OnboardingIllustrationWidget({
    super.key,
    required this.type,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OnboardingPainter(type),
      ),
    );
  }
}

class _OnboardingPainter extends CustomPainter {
  final OnboardingIllustration type;

  _OnboardingPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case OnboardingIllustration.farmDigitized:
        _paintFarmDigitized(canvas, size);
        break;
      case OnboardingIllustration.offline:
        _paintOffline(canvas, size);
        break;
      case OnboardingIllustration.smartInsights:
        _paintSmartInsights(canvas, size);
        break;
    }
  }

  void _paintFarmDigitized(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryContainer.withValues(alpha: 0.1);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primaryContainer
      ..strokeWidth = 2.0;

    // Main farm building
    final buildingRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.4,
      height: size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(buildingRect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(buildingRect, const Radius.circular(8)),
      strokePaint,
    );

    // Roof
    final path = Path()
      ..moveTo(buildingRect.left, buildingRect.top)
      ..lineTo(buildingRect.center.dx, buildingRect.top - size.height * 0.08)
      ..lineTo(buildingRect.right, buildingRect.top);
    canvas.drawPath(path, strokePaint..style = PaintingStyle.fill);

    // Data points floating around (representing digitization)
    final dataPoints = [
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.35),
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.2),
    ];

    for (final point in dataPoints) {
      canvas.drawCircle(point, 6, paint);
      canvas.drawCircle(point, 6, strokePaint);
    }

    // Connection lines
    final connectionPaint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < dataPoints.length - 1; i++) {
      canvas.drawLine(dataPoints[i], dataPoints[i + 1], connectionPaint);
    }
  }

  void _paintOffline(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.secondaryContainer.withValues(alpha: 0.1);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.secondaryContainer
      ..strokeWidth = 2.0;

    // Device/phone outline
    final deviceRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.25,
      height: size.height * 0.4,
    );

    final devicePath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(deviceRect, const Radius.circular(12)));
    canvas.drawPath(devicePath, paint);
    canvas.drawPath(devicePath, strokePaint);

    // Screen area
    final screenRect = Rect.fromCenter(
      center: deviceRect.center,
      width: deviceRect.width * 0.8,
      height: deviceRect.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );

    // Offline indicator (checkmark with cloud)
    final cloudCenter = Offset(size.width * 0.5, size.height * 0.35);
    canvas.drawCircle(cloudCenter, 15, paint);
    canvas.drawCircle(cloudCenter, 15, strokePaint);

    // Check mark
    final checkPath = Path()
      ..moveTo(cloudCenter.dx - 6, cloudCenter.dy)
      ..lineTo(cloudCenter.dx - 2, cloudCenter.dy + 4)
      ..lineTo(cloudCenter.dx + 6, cloudCenter.dy - 4);
    canvas.drawPath(checkPath, strokePaint..strokeWidth = 2.5);

    // Data sync lines (representing local storage)
    final dataLines = [
      Offset(size.width * 0.35, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.65),
    ];

    for (final line in dataLines) {
      canvas.drawLine(
        Offset(line.dx - 8, line.dy),
        Offset(line.dx + 8, line.dy),
        strokePaint..strokeWidth = 1.5,
      );
    }
  }

  void _paintSmartInsights(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.tertiaryContainer.withValues(alpha: 0.1);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.tertiaryContainer
      ..strokeWidth = 2.0;

    // Chart/graph representation
    final chartRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.55),
      width: size.width * 0.6,
      height: size.height * 0.3,
    );

    // Chart background
    canvas.drawRRect(
      RRect.fromRectAndRadius(chartRect, const Radius.circular(8)),
      paint,
    );

    // Chart bars (representing insights/analytics)
    final barPaint = Paint()
      ..color = AppColors.tertiaryContainer
      ..style = PaintingStyle.fill;

    final barPositions = [0.2, 0.35, 0.5, 0.65, 0.8];
    final barHeights = [0.4, 0.6, 0.8, 0.5, 0.7];

    for (int i = 0; i < barPositions.length; i++) {
      final barX = chartRect.left + chartRect.width * barPositions[i];
      final barWidth = chartRect.width * 0.08;
      final barHeight = chartRect.height * barHeights[i];
      final barRect = Rect.fromLTWH(
        barX - barWidth / 2,
        chartRect.bottom - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
        barPaint,
      );
    }

    // Trend line
    final trendPath = Path()
      ..moveTo(chartRect.left + chartRect.width * 0.2,
          chartRect.bottom - chartRect.height * 0.4)
      ..lineTo(chartRect.left + chartRect.width * 0.35,
          chartRect.bottom - chartRect.height * 0.6)
      ..lineTo(chartRect.left + chartRect.width * 0.5,
          chartRect.bottom - chartRect.height * 0.8)
      ..lineTo(chartRect.left + chartRect.width * 0.65,
          chartRect.bottom - chartRect.height * 0.5)
      ..lineTo(chartRect.left + chartRect.width * 0.8,
          chartRect.bottom - chartRect.height * 0.7);

    canvas.drawPath(trendPath, strokePaint);

    // Insight indicator (lightbulb/spark)
    final insightCenter = Offset(size.width * 0.5, size.height * 0.25);
    canvas.drawCircle(insightCenter, 18, paint);
    canvas.drawCircle(insightCenter, 18, strokePaint);

    // Spark lines from lightbulb
    final sparkPaint = Paint()
      ..color = AppColors.tertiaryContainer
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * 3.14159 / 180;
      final startPoint = Offset(
        insightCenter.dx + 20 * cos(angle),
        insightCenter.dy + 20 * sin(angle),
      );
      final endPoint = Offset(
        insightCenter.dx + 30 * cos(angle),
        insightCenter.dy + 30 * sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
