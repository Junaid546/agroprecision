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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: borderLeftColor ?? AppColors.surfaceContainerHigh,
            width: borderLeftColor != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (trendDirection == TrendDirection.up)
                          const Icon(Icons.trending_up_rounded,
                              size: 12, color: AppColors.primary),
                        if (trendDirection == TrendDirection.down)
                          const Icon(Icons.trending_down_rounded,
                              size: 12, color: AppColors.error),
                        if (trend != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              trend!,
                              style: AppTypography.labelBold.copyWith(
                                color: trendDirection == TrendDirection.down
                                    ? AppColors.error
                                    : AppColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: value is Widget
                            ? value as Widget
                            : Text(
                                value.toString(),
                                key: ValueKey<String>(value.toString()),
                                style: isHero
                                    ? AppTypography.displayStat
                                    : AppTypography.headlineLg
                                        .copyWith(fontSize: 24),
                              ),
                      ),
                      if (isHero && icon != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: icon!,
                        ),
                    ],
                  ),
                ),
                if (!isHero && icon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: icon!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
