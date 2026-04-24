import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../providers/connectivity_provider.dart';

class AgroAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showOfflineIndicator;
  final List<Widget>? actions;
  final bool showBackButton;

  const AgroAppBar({
    super.key,
    this.title = "AgroPrecision",
    this.showOfflineIndicator = true,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  const Icon(Icons.agriculture_rounded,
                      color: AppColors.primary, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.appBarTitle,
                  ),
                ),
                if (showOfflineIndicator)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isOnline
                        ? const Icon(Icons.cloud_done_rounded,
                            key: ValueKey('online'),
                            color: AppColors.primary,
                            size: 24)
                        : const Icon(Icons.cloud_off_rounded,
                            key: ValueKey('offline'),
                            color: AppColors.onSurfaceVariant,
                            size: 24),
                  ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
