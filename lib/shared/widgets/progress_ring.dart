import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

class CircularProgressRing extends StatelessWidget {
  final double percentage;
  final String label;
  final double size;
  final Color? color;

  const CircularProgressRing({
    super.key,
    required this.percentage,
    required this.label,
    this.size = 64,
    this.color,
  });

  Color _getStatusColor() {
    if (color != null) return color!;
    if (percentage >= 90) return const Color(0xFF14532D);
    if (percentage >= 70) return const Color(0xFFFEA619);
    return const Color(0xFFBA1A1A);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  percentage: percentage,
                  color: _getStatusColor(),
                  backgroundColor: AppColors.surfaceContainerHighest,
                  strokeWidth: 4,
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: AppTypography.labelBold,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
