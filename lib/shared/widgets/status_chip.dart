import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

enum ChipStatus { active, completed, priority, routine, done }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipStatus status;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;
    TextStyle textStyle = AppTypography.labelBold;

    switch (status) {
      case ChipStatus.active:
        bgColor = AppColors.activeChipBg;
        textColor = AppColors.activeChipText;
        border = const BorderSide(color: Colors.amber);
        break;
      case ChipStatus.completed:
        bgColor = AppColors.completedChipBg;
        textColor = AppColors.completedChipText;
        break;
      case ChipStatus.priority:
        bgColor = AppColors.priorityChipBg;
        textColor = AppColors.priorityChipText;
        border = const BorderSide(color: AppColors.error);
        break;
      case ChipStatus.routine:
        bgColor = AppColors.surfaceContainerLow;
        textColor = AppColors.onSurfaceVariant;
        break;
      case ChipStatus.done:
        bgColor = AppColors.surfaceContainerLow;
        textColor = AppColors.outline;
        textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
        break;
    }

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: StadiumBorder(side: border),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: textStyle.copyWith(color: textColor),
      ),
    );
  }
}
