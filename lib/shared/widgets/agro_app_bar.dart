import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

class AgroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showOfflineIndicator;

  const AgroAppBar({
    super.key,
    this.showOfflineIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.agriculture, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'AgroPrecision',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (showOfflineIndicator)
                Row(
                  children: [
                    Text(
                      'Offline Ready',
                      style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.cloud_off, color: AppColors.outline, size: 20),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
