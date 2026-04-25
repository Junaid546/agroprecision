import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/farm_preferences_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class AlertPreferencesScreen extends ConsumerStatefulWidget {
  const AlertPreferencesScreen({super.key});

  @override
  ConsumerState<AlertPreferencesScreen> createState() =>
      _AlertPreferencesScreenState();
}

class _AlertPreferencesScreenState
    extends ConsumerState<AlertPreferencesScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _smsAlerts = false;
  bool _mortalityAlerts = true;
  bool _feedAlerts = true;
  bool _environmentAlerts = true;
  bool _stockAlerts = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(farmPreferencesProvider);
    _pushNotifications = prefs.pushNotifications;
    _emailAlerts = prefs.emailAlerts;
    _smsAlerts = prefs.smsAlerts;
    _mortalityAlerts = prefs.mortalityAlerts;
    _feedAlerts = prefs.feedAlerts;
    _environmentAlerts = prefs.environmentAlerts;
    _stockAlerts = prefs.stockAlerts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert Preferences', style: AppTypography.headlineLg),
            Text(
              'Configure how and when you receive notifications.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text('CHANNELS',
                style:
                    AppTypography.labelBold.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Direct to your device'),
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Email Alerts'),
                    subtitle: const Text('Daily summary and critical alerts'),
                    value: _emailAlerts,
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('SMS Alerts'),
                    subtitle: const Text('Critical mortality alerts only'),
                    value: _smsAlerts,
                    onChanged: (v) => setState(() => _smsAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('ALERT TYPES',
                style:
                    AppTypography.labelBold.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mortality Spikes'),
                    subtitle: const Text('Notify when daily mortality > 1%'),
                    value: _mortalityAlerts,
                    onChanged: (v) => setState(() => _mortalityAlerts = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Feed Efficiency'),
                    subtitle: const Text('Alert when FCR drops below target'),
                    value: _feedAlerts,
                    onChanged: (v) => setState(() => _feedAlerts = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Environment Alerts'),
                    subtitle:
                        const Text('Temperature, humidity, ammonia, and CO2'),
                    value: _environmentAlerts,
                    onChanged: (v) => setState(() => _environmentAlerts = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Stock Alerts'),
                    subtitle: const Text('Low feed, medicine, and vaccine stock'),
                    value: _stockAlerts,
                    onChanged: (v) => setState(() => _stockAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    await ref.read(farmPreferencesServiceProvider).saveAlertPreferences(
          pushNotifications: _pushNotifications,
          emailAlerts: _emailAlerts,
          smsAlerts: _smsAlerts,
          mortalityAlerts: _mortalityAlerts,
          feedAlerts: _feedAlerts,
          environmentAlerts: _environmentAlerts,
          stockAlerts: _stockAlerts,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert preferences saved')),
      );
      Navigator.pop(context);
    }
  }
}
