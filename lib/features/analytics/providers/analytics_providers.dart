import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/expense_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../reports/models/report_models.dart';
import '../../reports/providers/report_providers.dart';
import '../../../data/models/growth_model.dart';

// CHART 1: Profit Trend
final profitTrendProvider =
    FutureProvider<List<BatchPerformanceRow>>((ref) async {
  final rows = await ref.watch(batchPerformanceListProvider.future);
  // Sort by date chronological for trend
  final trend = List<BatchPerformanceRow>.from(rows);
  trend.sort((a, b) => a.startDate.compareTo(b.startDate));
  return trend;
});

// CHART 2: Expense Distribution
final expenseDistributionProvider =
    FutureProvider<Map<ExpenseCategory, double>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return {};

  final batches = await ref.watch(batchRepositoryProvider).getByFarm(farm.id);
  final globalBreakdown = <ExpenseCategory, double>{};

  for (final batch in batches) {
    final breakdown = await ref
        .watch(expenseRepositoryProvider)
        .getCategoryBreakdown(batch.id);
    breakdown.forEach((category, amount) {
      globalBreakdown[category] = (globalBreakdown[category] ?? 0) + amount;
    });
  }

  return globalBreakdown;
});

// CHART 3: Weekly Mortality Trend
class WeeklyMortalityPoint {
  final int week;
  final double mortalityRate;
  WeeklyMortalityPoint(this.week, this.mortalityRate);
}

final mortalityTrendProvider =
    FutureProvider<List<WeeklyMortalityPoint>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];

  final batches = await ref.watch(batchRepositoryProvider).getByFarm(farm.id);
  if (batches.isEmpty) return [];

  // For simplicity and clarity in "Analytics", we'll aggregate mortality by week across ALL history
  // or focus on the latest 12 weeks of data.
  // The prompt says "Mortality Rate Over Time", usually implying a trend.

  final Map<int, List<double>> weeklyRates = {};

  for (final batch in batches) {
    final mortalityLogs =
        await ref.watch(mortalityRepositoryProvider).getByBatch(batch.id);
    for (final log in mortalityLogs) {
      final daysSinceStart = log.date.difference(batch.startDate).inDays;
      final week = (daysSinceStart / 7).floor() + 1;

      // Rate = (mortality / initialCount) * 100 for that specific log's week context
      final rate =
          batch.initialCount > 0 ? (log.count / batch.initialCount) * 100 : 0.0;

      weeklyRates[week] ??= [];
      weeklyRates[week]!.add(rate);
    }
  }

  final points = weeklyRates.entries.map((e) {
    final avgRate = e.value.reduce((a, b) => a + b) / e.value.length;
    return WeeklyMortalityPoint(e.key, avgRate);
  }).toList();

  points.sort((a, b) => a.week.compareTo(b.week));
  return points;
});

// CHART 4: FCR Trend
final fcrTrendProvider = FutureProvider<List<GrowthModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];

  final batches = await ref.watch(batchRepositoryProvider).getByFarm(farm.id);
  if (batches.isEmpty) return [];

  // Show FCR trend for the most recent batch
  final latestBatch =
      batches.reduce((a, b) => a.startDate.isAfter(b.startDate) ? a : b);
  final growthLogs =
      await ref.watch(growthRepositoryProvider).getByBatch(latestBatch.id);

  return growthLogs..sort((a, b) => a.batchDay.compareTo(b.batchDay));
});
