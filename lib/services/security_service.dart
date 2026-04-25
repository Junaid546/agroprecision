import '../data/models/security_settings.dart';
import 'hive_service.dart';

class SecurityService {
  static const String _securityKey = 'security_settings';

  SecuritySettingsData loadSettings() {
    final raw = HiveService.settingsBox.get(_securityKey);
    if (raw is Map) {
      return SecuritySettingsData.fromMap(raw);
    }
    return const SecuritySettingsData();
  }

  Future<void> saveSettings(SecuritySettingsData settings) async {
    await HiveService.settingsBox.put(_securityKey, settings.toMap());
  }

  bool verifyPin(String pin) {
    final settings = loadSettings();
    if (!settings.appLockEnabled || settings.pin == null) {
      return true;
    }
    return settings.pin == pin;
  }

  Future<void> configurePin({
    required bool enabled,
    required String? pin,
  }) async {
    await saveSettings(
      SecuritySettingsData(
        appLockEnabled: enabled,
        pin: enabled ? pin : null,
      ),
    );
  }
}
