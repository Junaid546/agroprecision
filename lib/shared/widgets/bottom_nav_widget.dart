import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class AgroBottomNav extends StatelessWidget {
  const AgroBottomNav({super.key});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/batches')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/batches');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: NavigationBar(
        height: 72,
        backgroundColor: AppColors.cardBackground,
        indicatorColor: AppColors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          _buildDestination(
            icon: Icons.grid_view_rounded,
            label: "DASHBOARD",
          ),
          _buildDestination(
            icon: Icons.inventory_2_rounded,
            label: "BATCHES",
          ),
          _buildDestination(
            icon: Icons.task_alt_rounded,
            label: "TASKS",
          ),
          _buildDestination(
            icon: Icons.bar_chart_rounded,
            label: "REPORTS",
          ),
          _buildDestination(
            icon: Icons.settings_rounded,
            label: "SETTINGS",
          ),
        ],
      ),
    );
  }

  NavigationDestination _buildDestination({
    required IconData icon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon, color: AppColors.onSurfaceVariant),
      selectedIcon: Icon(icon, color: AppColors.inversePrimary),
      label: label,
    );
  }
}
