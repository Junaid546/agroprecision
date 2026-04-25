import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/health_treatment_model.dart';
import '../../../data/models/inventory_item_model.dart';
import '../../../data/models/shed_environment_reading_model.dart';
import '../../../data/models/shed_model.dart';
import '../../../services/shed_operations_service.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';

final shedDetailsProvider =
    FutureProvider.autoDispose.family<ShedModel?, String>((ref, shedId) async {
  return ref.read(shedRepositoryProvider).getById(shedId);
});

final shedEnvironmentReadingsProvider = FutureProvider.autoDispose
    .family<List<ShedEnvironmentReadingModel>, String>((ref, shedId) async {
  return ref.read(shedEnvironmentRepositoryProvider).getByShed(shedId);
});

final shedOperationsSnapshotProvider = FutureProvider.autoDispose
    .family<ShedOperationsSnapshot, String>((ref, shedId) async {
  final shed = await ref.read(shedRepositoryProvider).getById(shedId);
  if (shed == null) {
    throw Exception('Shed not found');
  }
  final batch = shed.activeBatchId != null
      ? await ref.read(batchRepositoryProvider).getById(shed.activeBatchId!)
      : null;
  return ref
      .read(shedOperationsServiceProvider)
      .buildSnapshot(shed, activeBatch: batch);
});

final farmInventoryProvider =
    FutureProvider.autoDispose<List<InventoryItemModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) {
    return [];
  }
  return ref.read(inventoryRepositoryProvider).getByFarm(farm.id);
});

final lowStockItemsProvider =
    FutureProvider.autoDispose<List<InventoryItemModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) {
    return [];
  }
  return ref.read(inventoryRepositoryProvider).getLowStockItems(farm.id);
});

final farmTreatmentsProvider =
    FutureProvider.autoDispose<List<HealthTreatmentModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) {
    return [];
  }
  return ref.read(healthTreatmentRepositoryProvider).getByFarm(farm.id);
});
