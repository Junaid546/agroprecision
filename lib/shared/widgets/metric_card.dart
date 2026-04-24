import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

enum TrendDirection { up, down, neutral }

class MetricCard extends StatelessWidget {
  final String label;
  final dynamic value;
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
    final bool isHero = label == "ESTIMATED PROFIT";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: borderLeftColor != null
              ? Border(left: BorderSide(color: borderLeftColor!, width: 4))
              : Border.all(color: AppColors.surfaceVariant),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: value is Widget
                      ? value as Widget
                      : Text(
                          value.toString(),
                          key: ValueKey<String>(value.toString()),
                          style: isHero
                              ? AppTypography.displayStat
                              : AppTypography.headlineLg.copyWith(fontSize: 28),
                        ),
                ),
                if (isHero && icon != null) icon!,
              ],
            ),
            if (trend != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      if (trendDirection == TrendDirection.up)
                        const Icon(Icons.arrow_upward,
                            size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: AppTypography.labelBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isHero && icon != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: icon!,
              ),
          ],
        ),
      ),
    );
  }
}
