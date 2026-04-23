import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/task_model.dart';
import '../../../services/calculation_engine.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../batch/providers/batch_providers.dart';

// Dashboard summary — aggregated for the active batch
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return DashboardSummary.empty();

  // Get the primary active batch (most recent)
  final active = await ref.watch(activeBatchesProvider.future);
  if (active.isEmpty) return DashboardSummary.empty();

  final primaryBatch = active.first;
  final engine = ref.watch(calculationEngineProvider);
  final financials = await engine.computeForBatch(primaryBatch.id);
  final alerts = await engine.analyzeAndAlert(primaryBatch.id);
  final todayMortality = await ref
      .watch(mortalityRepositoryProvider)
      .getTodaysMortality(primaryBatch.id);
  final todayTasks =
      await ref.watch(taskRepositoryProvider).getByDate(DateTime.now());

  return DashboardSummary(
    batch: primaryBatch,
    financials: financials,
    alerts: alerts,
    todaysMortality: todayMortality,
    todaysTasks: todayTasks,
  );
});

class DashboardSummary {
  final BatchModel? batch;
  final BatchFinancials? financials;
  final List<ActionAlert> alerts;
  final int todaysMortality;
  final List<TaskModel> todaysTasks;

  DashboardSummary({
    this.batch,
    this.financials,
    required this.alerts,
    required this.todaysMortality,
    required this.todaysTasks,
  });

  factory DashboardSummary.empty() => DashboardSummary(
        alerts: [],
        todaysMortality: 0,
        todaysTasks: [],
      );
}
