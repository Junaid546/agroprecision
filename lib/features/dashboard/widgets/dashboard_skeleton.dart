import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _shimmerBox(width: 150, height: 32),
          const SizedBox(height: 8),
          _shimmerBox(width: 200, height: 20),
          const SizedBox(height: 16),
          _shimmerBox(width: double.infinity, height: 56, radius: 16),
          const SizedBox(height: 16),
          _shimmerBox(width: double.infinity, height: 80, radius: 16),
          const SizedBox(height: 8),
          _shimmerBox(width: double.infinity, height: 200, radius: 16),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 100, radius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(height: 100, radius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(width: double.infinity, height: 100, radius: 16),
          const SizedBox(height: 24),
          _shimmerBox(width: 150, height: 28),
          const SizedBox(height: 12),
          _shimmerBox(width: double.infinity, height: 200, radius: 16),
        ],
      ),
    );
  }

  Widget _shimmerBox({double? width, double? height, double radius = 8}) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant.withOpacity(0.5),
      highlightColor: AppColors.surface.withOpacity(0.2),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
