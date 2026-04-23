import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/calculation_engine.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';

// Farm-wide summary for reports screen
final farmSummaryProvider = FutureProvider<FarmSummaryFinancials>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null)
    return FarmSummaryFinancials(
        totalProfit: 0,
        totalRevenue: 0,
        totalCost: 0,
        overallROI: 0,
        batchCount: 0);
  return ref.watch(calculationEngineProvider).computeFarmSummary(farm.id);
});

// Batch performance table data
final batchPerformanceListProvider =
    FutureProvider<List<BatchPerformanceRow>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];

  final batches = await ref.watch(batchRepositoryProvider).getByFarm(farm.id);
  final engine = ref.watch(calculationEngineProvider);
  final rows = <BatchPerformanceRow>[];

  for (final batch in batches) {
    final f = await engine.computeForBatch(batch.id);
    rows.add(BatchPerformanceRow(
      batchId: batch.id,
      batchNumber: batch.batchNumber,
      startDate: batch.startDate,
      endDate: batch.endDate,
      revenue: f.totalRevenue,
      costs: f.totalCost,
      netProfit: f.netProfit,
      roi: f.roi,
    ));
  }
  rows.sort((a, b) => b.startDate.compareTo(a.startDate));
  return rows;
});

class BatchPerformanceRow {
  final String batchId;
  final String batchNumber;
  final DateTime startDate;
  final DateTime? endDate;
  final double revenue;
  final double costs;
  final double netProfit;
  final double roi;

  BatchPerformanceRow({
    required this.batchId,
    required this.batchNumber,
    required this.startDate,
    this.endDate,
    required this.revenue,
    required this.costs,
    required this.netProfit,
    required this.roi,
  });
}
