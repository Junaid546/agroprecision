import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/farm_model.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/models/batch_model.dart';
import 'repository_providers.dart';

// Current farm provider (loaded from Hive on app start)
final currentFarmProvider =
    StateNotifierProvider<CurrentFarmNotifier, FarmModel?>((ref) {
  return CurrentFarmNotifier(ref.watch(farmRepositoryProvider));
});

class CurrentFarmNotifier extends StateNotifier<FarmModel?> {
  final FarmRepository _repo;
  CurrentFarmNotifier(this._repo) : super(null) {
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    final farms = await _repo.getAll();
    if (farms.isNotEmpty) state = farms.first;
  }

  Future<void> createFarm(FarmModel farm) async {
    await _repo.create(farm);
    state = farm;
  }

  Future<void> updateFarm(FarmModel farm) async {
    await _repo.update(farm);
    state = farm;
  }
}

// Active batch provider (dashboard context)
final activeBatchProvider = StateProvider<BatchModel?>((ref) => null);

// Selected batch for detail view
final selectedBatchIdProvider = StateProvider<String?>((ref) => null);

// Connectivity provider
final connectivityProvider = StateProvider<bool>((ref) => false);
// Note: In offline-first app this is always false (no internet dependency)
// But we watch it to show/hide the cloud indicator in app bar
