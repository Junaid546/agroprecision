import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../services/calculation_engine.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/task_model.dart';
import '../../batch/providers/batch_providers.dart';
import '../../tasks/providers/task_providers.dart';

class DashboardSummary {
  final BatchModel? activeBatch;
  final BatchFinancials? financials;
  final List<ActionAlert> alerts;
  final int todaysMortality;
  final List<TaskModel> todaysTasks;
  final List<double> last5BatchesProfit;

  DashboardSummary({
    this.activeBatch,
    this.financials,
    this.alerts = const [],
    this.todaysMortality = 0,
    this.todaysTasks = const [],
    this.last5BatchesProfit = const [],
  });
}

final farmSummaryProvider = FutureProvider<FarmSummaryFinancials>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) throw Exception('No farm active');
  
  final engine = ref.watch(calculationEngineProvider);
  return engine.computeFarmSummary(farm.id);
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final activeBatch = ref.watch(autoSelectedBatchProvider);
  if (activeBatch == null) return DashboardSummary();

  final engine = ref.watch(calculationEngineProvider);
  final mortalityRepo = ref.watch(mortalityRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  final batchRepo = ref.watch(batchRepositoryProvider);

  final financials = await engine.computeForBatch(activeBatch.id);
  final alerts = await engine.analyzeAndAlert(activeBatch.id);
  final todaysMortality = await mortalityRepo.getTodaysMortality(activeBatch.id);
  
  // Use the tasks provider
  final todaysTasks = await ref.watch(tasksForDateProvider(DateTime.now()).future);

  // Get last 5 batches for the sparkline
  final allBatches = await batchRepo.getAll(); // sorted desc by default
  final last5 = allBatches.where((b) => b.status == BatchStatus.completed).take(5).toList().reversed.toList();
  
  List<double> last5Profit = [];
  for (var b in last5) {
    final fin = await engine.computeForBatch(b.id);
    last5Profit.add(fin.netProfit);
  }
  
  // Add current active batch profit
  last5Profit.add(financials.netProfit);

  return DashboardSummary(
    activeBatch: activeBatch,
    financials: financials,
    alerts: alerts,
    todaysMortality: todaysMortality,
    todaysTasks: todaysTasks,
    last5BatchesProfit: last5Profit,
  );
});

// Task action provider for toggling task status
final dashboardTaskActionProvider = Provider<DashboardTaskActionService>((ref) {
  return DashboardTaskActionService(ref);
});

class DashboardTaskActionService {
  final Ref _ref;
  DashboardTaskActionService(this._ref);

  Future<void> toggleTask(TaskModel task) async {
    final repo = _ref.read(taskRepositoryProvider);
    if (task.status == TaskStatus.done) {
      await repo.markPending(task.id);
    } else {
      await repo.markDone(task.id);
    }
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(tasksForDateProvider);
    _ref.invalidate(taskProgressProvider);
  }
}
