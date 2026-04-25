import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/farm_preferences.dart';
import 'app_state_provider.dart';

final farmPreferencesProvider = Provider<FarmPreferencesData>((ref) {
  final farm = ref.watch(currentFarmProvider);
  return FarmPreferencesData.fromMap(farm?.preferences);
});
