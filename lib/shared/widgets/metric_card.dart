import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

enum TrendDirection { up, down, neutral }

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final TrendDirection? trendDirection;
  final Widget? icon;
  final Color? borderLeftColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendDirection,
    this.icon,
    this.borderLeftColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: borderLeftColor != null
              ? Border(
                  left: BorderSide(color: borderLeftColor!, width: 4),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                if (icon != null) icon!,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.displayStat,
            ),
            if (trend != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (trendDirection == TrendDirection.up)
                    const Icon(Icons.north_east_rounded, color: AppColors.successText, size: 16)
                  else if (trendDirection == TrendDirection.down)
                    const Icon(Icons.south_east_rounded, color: AppColors.dangerText, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    trend!,
                    style: AppTypography.bodyMd.copyWith(
                      color: trendDirection == TrendDirection.up
                          ? AppColors.successText
                          : trendDirection == TrendDirection.down
                              ? AppColors.dangerText
                              : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
