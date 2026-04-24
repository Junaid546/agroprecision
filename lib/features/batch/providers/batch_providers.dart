import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/shed_model.dart';
import '../../../services/calculation_engine.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';

// --- CORE BATCH LIST ---

// Make this a proper AsyncNotifier so we can refresh it imperatively
final allBatchesProvider =
    AsyncNotifierProvider<AllBatchesNotifier, List<BatchModel>>(
  AllBatchesNotifier.new,
);

class AllBatchesNotifier extends AsyncNotifier<List<BatchModel>> {
  @override
  Future<List<BatchModel>> build() async {
    final farm = ref.watch(currentFarmProvider);
    if (farm == null) return [];
    return ref.read(batchRepositoryProvider).getByFarm(farm.id);
  }

  // Call this after any batch is created/updated/deleted
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final farm = ref.read(currentFarmProvider);
      if (farm == null) return [];
      return ref.read(batchRepositoryProvider).getByFarm(farm.id);
    });
  }
}

// Active batches derived from allBatchesProvider
final activeBatchesProvider = FutureProvider<List<BatchModel>>((ref) async {
  final all = await ref.watch(allBatchesProvider.future);
  return all.where((b) => b.status == BatchStatus.active).toList();
});

// --- SELECTION STATE ---

// Selected batch for dashboard context (manually set)
final activeBatchProvider = StateProvider<BatchModel?>((ref) => null);

// Auto-select active batch if none selected manually
final autoSelectedBatchProvider = Provider<BatchModel?>((ref) {
  final manualBatch = ref.watch(activeBatchProvider);
  if (manualBatch != null) return manualBatch;

  final batchesAsync = ref.watch(allBatchesProvider);
  return batchesAsync.when(
    data: (batches) {
      if (batches.isEmpty) return null;
      // Prefer active batches, then most recent
      try {
        return batches.firstWhere((b) => b.status == BatchStatus.active);
      } catch (_) {
        return batches.first;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// --- SHED PROVIDERS ---

final shedListProvider = FutureProvider<List<ShedModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  return ref.read(shedRepositoryProvider).getByFarm(farm.id);
});

// --- ANALYTICS (FAMILY) ---

// Batch financials for a specific batch
final batchFinancialsProvider = FutureProvider.autoDispose
    .family<BatchFinancials, String>((ref, batchId) async {
  final engine = ref.watch(calculationEngineProvider);
  return engine.computeForBatch(batchId);
});

// Batch alive count
final batchAliveCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, batchId) async {
  return ref.watch(batchRepositoryProvider).getCurrentAliveCount(batchId);
});

// Decision engine alerts for active batch
final batchAlertsProvider = FutureProvider.autoDispose
    .family<List<ActionAlert>, String>((ref, batchId) async {
  final engine = ref.watch(calculationEngineProvider);
  return engine.analyzeAndAlert(batchId);
});
