import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive & Register Adapters
  await HiveService.init();

  // Init Notifications
  await NotificationService.init();

  // Init timezone for notifications
  tz.initializeTimeZones();

  runApp(
    const ProviderScope(
      child: PoultryPathApp(),
    ),
  );
}
