import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Imports for features
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/farm_setup_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/batch/screens/batch_list_screen.dart';
import '../../features/batch/screens/create_batch_screen.dart';
import '../../features/batch/screens/batch_detail_screen.dart';

// Imports for data/shared
import '../../shared/providers/app_state_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// Custom transitions helper
class AppTransitions {
  static CustomTransitionPage fade({
    required LocalKey key,
    required Widget child,
    int durationMs = 150,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage slideRight({
    required LocalKey key,
    required Widget child,
    int durationMs = 200,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage slideBottom({
    required LocalKey key,
    required Widget child,
    int durationMs = 300,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

class AgroBottomNav extends StatelessWidget {
  final Widget child;

  const AgroBottomNav({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/batches')) return 1;
    if (location.startsWith('/home/tasks')) return 2;
    if (location.startsWith('/home/reports')) return 3;
    if (location.startsWith('/home/settings')) return 4;
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/dashboard');
        break;
      case 1:
        context.go('/home/batches');
        break;
      case 2:
        context.go('/home/tasks');
        break;
      case 3:
        context.go('/home/reports');
        break;
      case 4:
        context.go('/home/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final farm = ref.watch(currentFarmProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Allow Splash screen at / to handle its own navigation
      if (location == '/') return null;

      // If no farm exists and not on onboarding, redirect to onboarding
      if (farm == null && !location.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // If farm exists and on onboarding, redirect to dashboard
      if (farm != null && location.startsWith('/onboarding')) {
        return '/home/dashboard';
      }

      // Basic redirect for /home
      if (location == '/home') {
        return '/home/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'setup',
            builder: (context, state) => const FarmSetupScreen(),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AgroBottomNav(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/home/dashboard',
            pageBuilder: (context, state) => AppTransitions.fade(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          // Batches
          GoRoute(
            path: '/home/batches',
            pageBuilder: (context, state) => AppTransitions.fade(
              key: state.pageKey,
              child: const BatchListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey, // Above bottom nav
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const CreateBatchScreen(),
                ),
              ),
              GoRoute(
                path: ':batchId',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const BatchDetailScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add-expense',
                    parentNavigatorKey: _rootNavigatorKey, // Above bottom nav
                    pageBuilder: (context, state) => AppTransitions.slideBottom(
                      key: state.pageKey,
                      child: const AddExpenseScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'add-mortality',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppTransitions.slideBottom(
                      key: state.pageKey,
                      child: const AddMortalityScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'add-growth',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppTransitions.slideBottom(
                      key: state.pageKey,
                      child: const AddGrowthScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'add-sale',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppTransitions.slideBottom(
                      key: state.pageKey,
                      child: const AddSaleScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tasks
          GoRoute(
            path: '/home/tasks',
            pageBuilder: (context, state) => AppTransitions.fade(
              key: state.pageKey,
              child: const TasksScreen(),
            ),
          ),
          // Reports
          GoRoute(
            path: '/home/reports',
            pageBuilder: (context, state) => AppTransitions.fade(
              key: state.pageKey,
              child: const ReportsScreen(),
            ),
          ),
          // Settings
          GoRoute(
            path: '/home/settings',
            pageBuilder: (context, state) => AppTransitions.fade(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'farm-profile',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const FarmProfileScreen(),
                ),
              ),
              GoRoute(
                path: 'sheds',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const ShedManagementScreen(),
                ),
              ),
              GoRoute(
                path: 'alert-preferences',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const AlertPreferencesScreen(),
                ),
              ),
              GoRoute(
                path: 'data-export',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const DataExportScreen(),
                ),
              ),
              GoRoute(
                path: 'backup',
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  key: state.pageKey,
                  child: const BackupScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
// --- SCREEN STUBS (To be moved to features/ as implemented) ---


// These will be implemented in their respective feature folders
class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: const Center(child: Text('Add Expense Form')),
      );
}

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: const Center(child: Text('Add Expense Form')),
      );
}

class AddMortalityScreen extends StatelessWidget {
  const AddMortalityScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Mortality')),
        body: const Center(child: Text('Add Mortality Form')),
      );
}

class AddGrowthScreen extends StatelessWidget {
  const AddGrowthScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Growth')),
        body: const Center(child: Text('Add Growth Form')),
      );
}

class AddSaleScreen extends StatelessWidget {
  const AddSaleScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Sale')),
        body: const Center(child: Text('Add Sale Form')),
      );
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tasks')));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Reports')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings')));
}

class FarmProfileScreen extends StatelessWidget {
  const FarmProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Farm Profile')),
        body: const Center(child: Text('Farm Profile Settings')),
      );
}

class ShedManagementScreen extends StatelessWidget {
  const ShedManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Shed Management')),
        body: const Center(child: Text('Shed List and Management')),
      );
}

class AlertPreferencesScreen extends StatelessWidget {
  const AlertPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Alert Preferences')),
        body: const Center(child: Text('Notification and Alert Settings')),
      );
}

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Data Export')),
        body: const Center(child: Text('Export Data to CSV/Excel')),
      );
}

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Backup & Restore')),
        body: const Center(child: Text('Database Backup Settings')),
      );
}
