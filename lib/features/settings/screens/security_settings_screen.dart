import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/security_settings.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../security/providers/security_providers.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _enableLock = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(securitySettingsProvider);
    _enableLock = settings.appLockEnabled;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(securitySettingsProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security Settings', style: AppTypography.headlineLg),
            Text(
              'Protect the app with a local PIN without changing any existing farm workflows.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable App Lock'),
                    subtitle:
                        const Text('Require a 4-digit PIN when opening the app'),
                    value: _enableLock,
                    onChanged: (value) => setState(() => _enableLock = value),
                  ),
                  if (_enableLock) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'New PIN',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm PIN',
                              counterText: '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _save(settings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Security Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(SecuritySettingsData currentSettings) async {
    if (_enableLock) {
      final pin = _pinController.text.trim();
      final confirm = _confirmPinController.text.trim();
      if (pin.length != 4 || pin != confirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN must be 4 digits and match confirmation'),
          ),
        );
        return;
      }
      await ref
          .read(securitySettingsProvider.notifier)
          .configurePin(enabled: true, pin: pin);
      ref.read(securityUnlockedProvider.notifier).state = true;
    } else {
      await ref
          .read(securitySettingsProvider.notifier)
          .configurePin(enabled: false, pin: null);
      ref.read(securityUnlockedProvider.notifier).state = false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security settings saved')),
      );
      Navigator.pop(context);
    }
  }
}
