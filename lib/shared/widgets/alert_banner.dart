import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

enum AlertType { danger, warning, info, success }

class AlertBanner extends StatelessWidget {
  final AlertType type;
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    IconData iconData;
    Color titleColor;
    Border? border;

    switch (type) {
      case AlertType.danger:
        bgColor = AppColors.errorContainer;
        iconColor = AppColors.error;
        iconData = Icons.warning_amber_rounded;
        titleColor = AppColors.error;
        border = Border.all(color: AppColors.error.withOpacity(0.3));
        break;
      case AlertType.warning:
        bgColor = const Color(0xFFFFF3E0);
        iconColor = AppColors.secondary;
        iconData = Icons.trending_down_rounded;
        titleColor = AppColors.secondary;
        break;
      case AlertType.info:
        bgColor = AppColors.surfaceContainerLow;
        iconColor = AppColors.primary;
        iconData = Icons.info_outline_rounded;
        titleColor = AppColors.primary;
        break;
      case AlertType.success:
        bgColor = AppColors.successBackground;
        iconColor = AppColors.successText;
        iconData = Icons.check_circle_outline_rounded;
        titleColor = AppColors.successText;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: border,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodyMd.copyWith(color: titleColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close_rounded, color: iconColor, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
