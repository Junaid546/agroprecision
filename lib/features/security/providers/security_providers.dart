import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/security_settings.dart';
import '../../../shared/providers/repository_providers.dart';

final securitySettingsProvider =
    StateNotifierProvider<SecuritySettingsNotifier, SecuritySettingsData>((ref) {
  return SecuritySettingsNotifier(ref);
});

final securityUnlockedProvider = StateProvider<bool>((ref) => false);

class SecuritySettingsNotifier extends StateNotifier<SecuritySettingsData> {
  final Ref _ref;

  SecuritySettingsNotifier(this._ref)
      : super(_ref.read(securityServiceProvider).loadSettings());

  Future<void> save(SecuritySettingsData settings) async {
    await _ref.read(securityServiceProvider).saveSettings(settings);
    state = settings;
  }

  Future<void> configurePin({
    required bool enabled,
    required String? pin,
  }) async {
    final settings = SecuritySettingsData(
      appLockEnabled: enabled,
      pin: enabled ? pin : null,
    );
    await save(settings);
  }
}
