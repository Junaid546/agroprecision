import 'package:flutter/foundation.dart';
import '../data/models/batch_model.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/batch_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/growth_repository.dart';
import '../data/repositories/mortality_repository.dart';
import '../data/repositories/sale_repository.dart';

enum AlertType { danger, warning, success, info }

class BatchFinancials {
  final String batchId;
  final int initialCount;
  final double initialCostPerBird;
  final double totalExpenses;
  final double totalRevenue;
  final int totalMortality;
  final int currentAlive;
  final int totalSold;
  final double? latestWeightKg;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final BatchStatus status;

  BatchFinancials({
    required this.batchId,
    required this.initialCount,
    required this.initialCostPerBird,
    required this.totalExpenses,
    required this.totalRevenue,
    required this.totalMortality,
    required this.currentAlive,
    required this.totalSold,
    this.latestWeightKg,
    required this.categoryBreakdown,
    required this.status,
  });

  // DERIVED — All calculated, never stored
  double get purchaseCost => initialCount * initialCostPerBird;
  double get totalCost => purchaseCost + totalExpenses;
  double get netProfit => totalRevenue - totalCost;
  double get mortalityRate =>
      initialCount > 0 ? (totalMortality / initialCount) * 100 : 0.0;
  double get survivalRate => 100.0 - mortalityRate;
  double get costPerBird => (initialCount - totalMortality) > 0
      ? totalCost / (initialCount - totalMortality)
      : 0.0;
  double get revenuePerBird => totalSold > 0 ? totalRevenue / totalSold : 0.0;
  double get roi => totalCost > 0 ? (netProfit / totalCost) * 100 : 0.0;

  double get breakEvenPricePerKg {
    if (latestWeightKg == null || latestWeightKg! <= 0 || currentAlive <= 0) {
      return 0;
    }
    return totalCost / (currentAlive * latestWeightKg!);
  }

  double get performanceScore {
    final score = (survivalRate * 0.4) + (roi * 0.4);
    return score.clamp(0.0, 100.0);
  }

  bool get isProfitable => netProfit > 0;
}

class FarmSummaryFinancials {
  final double totalProfit;
  final double totalRevenue;
  final double totalCost;
  final double overallROI;
  final int batchCount;
  final double avgCostPerBird;

  FarmSummaryFinancials({
    required this.totalProfit,
    required this.totalRevenue,
    required this.totalCost,
    required this.overallROI,
    required this.batchCount,
    required this.avgCostPerBird,
  });
}

class ActionAlert {
  final AlertType type;
  final String title;
  final String message;
  final String metric;

  ActionAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.metric,
  });
}

class CalculationEngine {
  final ExpenseRepository _expenseRepo;
  final MortalityRepository _mortalityRepo;
  final SaleRepository _saleRepo;
  final GrowthRepository _growthRepo;
  final BatchRepository _batchRepo;

  CalculationEngine({
    required ExpenseRepository expenseRepo,
    required MortalityRepository mortalityRepo,
    required SaleRepository saleRepo,
    required GrowthRepository growthRepo,
    required BatchRepository batchRepo,
  })  : _expenseRepo = expenseRepo,
        _mortalityRepo = mortalityRepo,
        _saleRepo = saleRepo,
        _growthRepo = growthRepo,
        _batchRepo = batchRepo;

  Future<BatchFinancials> computeForBatch(String batchId) async {
    final batch = await _batchRepo.getById(batchId);
    if (batch == null) throw Exception('Batch not found: $batchId');

    final expenses = await _expenseRepo.getTotalForBatch(batchId);
    final revenue = await _saleRepo.getTotalRevenueForBatch(batchId);
    final mortalityCount = await _mortalityRepo.getTotalForBatch(batchId);

    final sales = await _saleRepo.getTotalSoldForBatch(batchId);

    final latestGrowth = await _growthRepo.getLatest(batchId);
    final categoryBreakdown = await _expenseRepo.getCategoryBreakdown(batchId);

    return BatchFinancials(
      batchId: batchId,
      initialCount: batch.initialCount,
      initialCostPerBird: batch.initialCostPerBird,
      totalExpenses: expenses,
      totalRevenue: revenue,
      totalMortality: mortalityCount,
      currentAlive: batch.initialCount - mortalityCount - sales,
      totalSold: sales,
      latestWeightKg: latestGrowth?.averageWeightKg,
      categoryBreakdown: categoryBreakdown,
      status: batch.status,
    );
  }

  Future<FarmSummaryFinancials> computeFarmSummary(String farmId) async {
    final batches = await _batchRepo.getByFarm(farmId);
    double totalProfit = 0;
    double totalRevenue = 0;
    double totalCost = 0;
    int totalBirds = 0;

    for (final batch in batches) {
      final f = await computeForBatch(batch.id);
      totalProfit += f.netProfit;
      totalRevenue += f.totalRevenue;
      totalCost += f.totalCost;
      totalBirds += (f.initialCount - f.totalMortality);
    }

    final overallROI = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0;
    final avgCostPerBird = totalBirds > 0 ? totalCost / totalBirds : 0.0;

    return FarmSummaryFinancials(
      totalProfit: totalProfit,
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      overallROI: overallROI,
      batchCount: batches.length,
      avgCostPerBird: avgCostPerBird,
    );
  }

  Future<List<ActionAlert>> analyzeAndAlert(String batchId) async {
    final financials = await computeForBatch(batchId);
    final List<ActionAlert> alerts = [];

    // RULE 1: Mortality spike (> 1% in a single day)
    final todayMortality = await _mortalityRepo.getTodaysMortality(batchId);
    final dailyMortalityThreshold = (financials.initialCount * 0.01).ceil();
    if (todayMortality >= dailyMortalityThreshold &&
        financials.initialCount > 0) {
      alerts.add(ActionAlert(
        type: AlertType.danger,
        title: 'Mortality Warning',
        message:
            "Today's mortality rate exceeds acceptable threshold. Immediate inspection required.",
        metric: 'mortality',
      ));
    }

    // RULE 2: Feed inefficiency (FCR > 2.0)
    final latestGrowth = await _growthRepo.getLatest(batchId);
    if (latestGrowth != null && latestGrowth.feedConversionRatio > 2.0) {
      alerts.add(ActionAlert(
        type: AlertType.warning,
        title: 'Low Feed Inefficiency',
        message:
            'Feed conversion ratio is dropping below target for Day ${latestGrowth.batchDay}.',
        metric: 'fcr',
      ));
    }

    // RULE 3: Cumulative mortality rate > 5%
    if (financials.mortalityRate > 5.0) {
      alerts.add(ActionAlert(
        type: AlertType.danger,
        title: 'High Cumulative Mortality',
        message:
            '${financials.mortalityRate.toStringAsFixed(1)}% mortality rate exceeds 5% threshold.',
        metric: 'mortality_cumulative',
      ));
    }

    // RULE 4: High ROI — reinvestment suggestion
    if (financials.roi > 20.0 && financials.status == BatchStatus.completed) {
      alerts.add(ActionAlert(
        type: AlertType.success,
        title: 'Strong ROI — Consider Reinvesting',
        message:
            '${financials.roi.toStringAsFixed(1)}% ROI achieved. Consider scaling next batch.',
        metric: 'roi_high',
      ));
    }

    return alerts;
  }
}
