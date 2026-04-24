import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../services/calculation_engine.dart';

class AlertBanner extends StatelessWidget {
  final AlertType type;
  final String title;
  final String message;

  const AlertBanner({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDanger = type == AlertType.danger;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color:
            isDanger ? AppColors.errorContainer : AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDanger ? AppColors.error : AppColors.secondary)
              .withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDanger ? Icons.warning_rounded : Icons.trending_down_rounded,
            color: isDanger ? AppColors.error : AppColors.secondary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.inlineGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineMd.copyWith(
                    color: isDanger
                        ? AppColors.error
                        : AppColors.onSecondaryContainer,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
