import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget skeletonCard() {
    return const LoadingSkeleton(
      width: double.infinity,
      height: 120,
    );
  }

  static Widget skeletonMetric() {
    return const Row(
      children: [
        LoadingSkeleton(width: 48, height: 48, borderRadius: 24),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingSkeleton(width: 120, height: 16),
              SizedBox(height: 8),
              LoadingSkeleton(width: 80, height: 24),
            ],
          ),
        ),
      ],
    );
  }

  static Widget skeletonList() {
    return Column(
      children: List.generate(
          5,
          (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: skeletonMetric(),
              )),
    );
  }
}
