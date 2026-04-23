import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/batch_model.dart';
import '../../../services/calculation_engine.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';

// All batches for current farm
final allBatchesProvider = FutureProvider<List<BatchModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  return ref.watch(batchRepositoryProvider).getByFarm(farm.id);
});

// Active batches only
final activeBatchesProvider = FutureProvider<List<BatchModel>>((ref) async {
  final all = await ref.watch(allBatchesProvider.future);
  return all.where((b) => b.status == BatchStatus.active).toList();
});

// Batch financials for a specific batch (family provider)
final batchFinancialsProvider =
    FutureProvider.family<BatchFinancials, String>((ref, batchId) async {
  final engine = ref.watch(calculationEngineProvider);
  return engine.computeForBatch(batchId);
});

// Batch alive count (family)
final batchAliveCountProvider =
    FutureProvider.family<int, String>((ref, batchId) async {
  return ref.watch(batchRepositoryProvider).getCurrentAliveCount(batchId);
});

// Decision engine alerts for active batch
final batchAlertsProvider =
    FutureProvider.family<List<ActionAlert>, String>((ref, batchId) async {
  final engine = ref.watch(calculationEngineProvider);
  return engine.analyzeAndAlert(batchId);
});
