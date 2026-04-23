import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';

class AgroPrecisionApp extends ConsumerWidget {
  const AgroPrecisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Dashboard'))),
        ),
        GoRoute(
          path: '/batches',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Batches'))),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Tasks'))),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Reports'))),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Settings'))),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AgroPrecision',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
