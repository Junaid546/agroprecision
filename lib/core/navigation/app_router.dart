import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_state_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/farm_setup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Onboarding')));
}

class FarmSetupScreen extends StatelessWidget {
  const FarmSetupScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Farm Setup')));
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
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Batches'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Dashboard'));
}

class BatchListScreen extends StatelessWidget {
  const BatchListScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Batch List'));
}

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Batch Detail'));
}

class CreateBatchScreen extends StatelessWidget {
  const CreateBatchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Create Batch'));
}

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Add Expense'));
}

class AddMortalityScreen extends StatelessWidget {
  const AddMortalityScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Add Mortality'));
}

class AddGrowthScreen extends StatelessWidget {
  const AddGrowthScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Add Growth'));
}

class AddSaleScreen extends StatelessWidget {
  const AddSaleScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Add Sale'));
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Tasks'));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Reports'));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Settings'));
}

class FarmProfileScreen extends StatelessWidget {
  const FarmProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Farm Profile'));
}

class ShedManagementScreen extends StatelessWidget {
  const ShedManagementScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Shed Management'));
}

class AlertPreferencesScreen extends StatelessWidget {
  const AlertPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Alert Preferences'));
}

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Data Export'));
}

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Backup'));
}

// Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final farmAsync = ref.watch(currentFarmProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // For async operations, we need to handle this differently
      // For now, assume farm is loaded synchronously
      final farm = farmAsync;
      final location = state.matchedLocation;

      // If no farm exists and not on onboarding/setup, redirect to onboarding
      if (farm == null && !location.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // If farm exists and on root, redirect to home
      if (farm != null && location == '/') {
        return '/home/dashboard';
      }

      return null;
    },
    routes: [
      // Splash route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding routes
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

      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) => AgroBottomNav(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/home/dashboard',
            builder: (context, state) => const DashboardScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 150),
            ),
          ),

          // Batches
          GoRoute(
            path: '/home/batches',
            builder: (context, state) => const BatchListScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BatchListScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 150),
            ),
            routes: [
              // Batch detail with tabs
              GoRoute(
                path: ':batchId',
                builder: (context, state) => const BatchDetailScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const BatchDetailScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
                routes: [
                  GoRoute(
                    path: 'add-expense',
                    builder: (context, state) => const AddExpenseScreen(),
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const AddExpenseScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  GoRoute(
                    path: 'add-mortality',
                    builder: (context, state) => const AddMortalityScreen(),
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const AddMortalityScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  GoRoute(
                    path: 'add-growth',
                    builder: (context, state) => const AddGrowthScreen(),
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const AddGrowthScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  GoRoute(
                    path: 'add-sale',
                    builder: (context, state) => const AddSaleScreen(),
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const AddSaleScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),

              // Create batch
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateBatchScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const CreateBatchScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
            ],
          ),

          // Tasks
          GoRoute(
            path: '/home/tasks',
            builder: (context, state) => const TasksScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TasksScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 150),
            ),
          ),

          // Reports
          GoRoute(
            path: '/home/reports',
            builder: (context, state) => const ReportsScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ReportsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 150),
            ),
          ),

          // Settings
          GoRoute(
            path: '/home/settings',
            builder: (context, state) => const SettingsScreen(),
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 150),
            ),
            routes: [
              GoRoute(
                path: 'farm-profile',
                builder: (context, state) => const FarmProfileScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const FarmProfileScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
              GoRoute(
                path: 'sheds',
                builder: (context, state) => const ShedManagementScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ShedManagementScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
              GoRoute(
                path: 'alert-preferences',
                builder: (context, state) => const AlertPreferencesScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AlertPreferencesScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
              GoRoute(
                path: 'data-export',
                builder: (context, state) => const DataExportScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const DataExportScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
              GoRoute(
                path: 'backup',
                builder: (context, state) => const BackupScreen(),
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const BackupScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class FarmModel {
  // Placeholder
}

class FarmRepository {
  // Placeholder
}
