import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/farm_preferences.dart';
import '../shared/providers/app_state_provider.dart';

class FarmPreferencesService {
  final Ref _ref;

  FarmPreferencesService(this._ref);

  FarmPreferencesData get currentPreferences {
    final farm = _ref.read(currentFarmProvider);
    return FarmPreferencesData.fromMap(farm?.preferences);
  }

  Future<void> savePreferences(FarmPreferencesData preferences) async {
    final farm = _ref.read(currentFarmProvider);
    if (farm == null) {
      return;
    }

    final updated = farm.copyWith(
      updatedAt: DateTime.now(),
      preferences: preferences.toMap(),
    );
    await _ref.read(currentFarmProvider.notifier).updateFarm(updated);
  }

  Future<void> saveAlertPreferences({
    required bool pushNotifications,
    required bool emailAlerts,
    required bool smsAlerts,
    required bool mortalityAlerts,
    required bool feedAlerts,
    required bool environmentAlerts,
    required bool stockAlerts,
  }) async {
    final current = currentPreferences;
    await savePreferences(
      current.copyWith(
        pushNotifications: pushNotifications,
        emailAlerts: emailAlerts,
        smsAlerts: smsAlerts,
        mortalityAlerts: mortalityAlerts,
        feedAlerts: feedAlerts,
        environmentAlerts: environmentAlerts,
        stockAlerts: stockAlerts,
      ),
    );
  }

  bool isAlertEnabled(String metric) {
    final prefs = currentPreferences;
    switch (metric) {
      case 'mortality':
      case 'mortality_cumulative':
        return prefs.mortalityAlerts;
      case 'fcr':
        return prefs.feedAlerts;
      case 'environment':
        return prefs.environmentAlerts;
      case 'stock':
        return prefs.stockAlerts;
      default:
        return true;
    }
  }
}
