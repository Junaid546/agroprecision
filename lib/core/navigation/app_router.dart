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
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/farm_profile_screen.dart';
import '../../features/settings/screens/shed_management_screen.dart';
import '../../features/settings/screens/alert_preferences_screen.dart';
import '../../features/settings/screens/data_export_screen.dart';
import '../../features/settings/screens/backup_screen.dart';

import '../../features/batch/screens/activity_screens.dart';
import 'package:flutter/services.dart';
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
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
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
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

class AgroBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AgroBottomNav({super.key, required this.navigationShell});

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onItemTapped,
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
      if (location == '/') return null;
      if (farm == null && !location.startsWith('/onboarding')) {
        return '/onboarding';
      }
      if (farm != null && location.startsWith('/onboarding')) {
        return '/home/dashboard';
      }
      if (location == '/home') return '/home/dashboard';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AgroBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                pageBuilder: (context, state) => AppTransitions.fade(
                  key: state.pageKey,
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          // Batches
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/batches',
                pageBuilder: (context, state) => AppTransitions.fade(
                  key: state.pageKey,
                  child: const BatchListScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppTransitions.slideRight(
                      key: state.pageKey,
                      child: const CreateBatchScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':batchId',
                    pageBuilder: (context, state) => AppTransitions.slideRight(
                      key: state.pageKey,
                      child: BatchDetailScreen(
                          batchId: state.pathParameters['batchId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'add-expense',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            AppTransitions.slideBottom(
                          key: state.pageKey,
                          child: AddExpenseScreen(
                              batchId: state.pathParameters['batchId']!),
                        ),
                      ),
                      GoRoute(
                        path: 'add-mortality',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            AppTransitions.slideBottom(
                          key: state.pageKey,
                          child: AddMortalityScreen(
                              batchId: state.pathParameters['batchId']!),
                        ),
                      ),
                      GoRoute(
                        path: 'add-growth',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            AppTransitions.slideBottom(
                          key: state.pageKey,
                          child: AddGrowthScreen(
                              batchId: state.pathParameters['batchId']!),
                        ),
                      ),
                      GoRoute(
                        path: 'add-sale',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) =>
                            AppTransitions.slideBottom(
                          key: state.pageKey,
                          child: AddSaleScreen(
                              batchId: state.pathParameters['batchId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/tasks',
                pageBuilder: (context, state) => AppTransitions.fade(
                  key: state.pageKey,
                  child: const TasksScreen(),
                ),
              ),
            ],
          ),
          // Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/reports',
                pageBuilder: (context, state) => AppTransitions.fade(
                  key: state.pageKey,
                  child: const ReportsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'analytics',
                    pageBuilder: (context, state) => AppTransitions.slideRight(
                      key: state.pageKey,
                      child: const AnalyticsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Settings
          StatefulShellBranch(
            routes: [
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
      ),
    ],
  );
});
