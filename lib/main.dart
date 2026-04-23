import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Init Hive
  await Hive.initFlutter();
  
  // Register all Hive adapters (placeholders for now)
  // TODO: Add adapters here as models are created
  
  // Init timezone for notifications
  tz.initializeTimeZones();
  
  runApp(
    const ProviderScope(
      child: AgroPrecisionApp(),
    ),
  );
}
