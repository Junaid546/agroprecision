import '../../../data/models/expense_model.dart';
import '../../../data/models/farm_model.dart';
import '../../../data/repositories/batch_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/growth_repository.dart';
import '../../../data/repositories/mortality_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../services/calculation_engine.dart';
import '../models/report_models.dart';

abstract class ReportExportAssembler {
  Future<ReportExportPayload> buildReport({
    required FarmModel? farm,
    required FarmSummaryFinancials summary,
    required List<BatchPerformanceRow> performanceRows,
  });
}

class DefaultReportExportAssembler implements ReportExportAssembler {
  final BatchRepository _batchRepository;
  final ExpenseRepository _expenseRepository;
  final MortalityRepository _mortalityRepository;
  final GrowthRepository _growthRepository;
  final SaleRepository _saleRepository;
  final CalculationEngine _calculationEngine;

  const DefaultReportExportAssembler({
    required BatchRepository batchRepository,
    required ExpenseRepository expenseRepository,
    required MortalityRepository mortalityRepository,
    required GrowthRepository growthRepository,
    required SaleRepository saleRepository,
    required CalculationEngine calculationEngine,
  })  : _batchRepository = batchRepository,
        _expenseRepository = expenseRepository,
        _mortalityRepository = mortalityRepository,
        _growthRepository = growthRepository,
        _saleRepository = saleRepository,
        _calculationEngine = calculationEngine;

  @override
  Future<ReportExportPayload> buildReport({
    required FarmModel? farm,
    required FarmSummaryFinancials summary,
    required List<BatchPerformanceRow> performanceRows,
  }) async {
    final batchDetails = <ReportBatchDetail>[];
    final expenseMix = <ExpenseCategory, double>{};
    var totalBirdsPlaced = 0;
    var totalBirdsSold = 0;
    var totalBirdsAlive = 0;
    var totalBirdsDead = 0;

    for (final row in performanceRows) {
      final batch = await _batchRepository.getById(row.batchId);
      if (batch == null) {
        continue;
      }

      try {
        final financials =
            await _calculationEngine.computeForBatch(row.batchId);
        final expenses = (await _expenseRepository.getByBatch(row.batchId))
            .take(10)
            .toList();
        final sales =
            (await _saleRepository.getByBatch(row.batchId)).take(10).toList();
        final mortality = (await _mortalityRepository.getByBatch(row.batchId))
            .take(10)
            .toList();
        final growthLogs = await _growthRepository.getByBatch(row.batchId);
        final growth = growthLogs.reversed.take(10).toList();

        for (final entry in financials.categoryBreakdown.entries) {
          expenseMix[entry.key] = (expenseMix[entry.key] ?? 0) + entry.value;
        }

        totalBirdsPlaced += financials.initialCount;
        totalBirdsSold += financials.totalSold;
        totalBirdsAlive += financials.currentAlive;
        totalBirdsDead += financials.totalMortality;

        batchDetails.add(
          ReportBatchDetail(
            batch: batch,
            financials: financials,
            performance: row,
            recentExpenses: expenses,
            recentSales: sales,
            recentMortality: mortality,
            recentGrowth: growth,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    batchDetails.sort(
      (a, b) => b.batch.startDate.compareTo(a.batch.startDate),
    );

    final rankedByProfit = List<ReportBatchDetail>.from(batchDetails)
      ..sort(
          (a, b) => b.financials.netProfit.compareTo(a.financials.netProfit));

    final topBatch = rankedByProfit.isEmpty
        ? null
        : ReportBatchHighlight(
            batchNumber: rankedByProfit.first.batch.batchNumber,
            netProfit: rankedByProfit.first.financials.netProfit,
            roi: rankedByProfit.first.financials.roi,
            status: rankedByProfit.first.batch.status,
          );

    final weakestBatch = rankedByProfit.isEmpty
        ? null
        : ReportBatchHighlight(
            batchNumber: rankedByProfit.last.batch.batchNumber,
            netProfit: rankedByProfit.last.financials.netProfit,
            roi: rankedByProfit.last.financials.roi,
            status: rankedByProfit.last.batch.status,
          );

    return ReportExportPayload(
      farm: farm,
      farmName: farm?.name ?? 'AgroPrecision Farm',
      ownerName: farm?.ownerName ?? 'Farm Owner',
      location: farm?.location,
      phone: farm?.phone,
      generatedAt: DateTime.now(),
      summary: summary,
      batchPerformanceRows: performanceRows,
      batches: batchDetails,
      insights: ReportFarmInsights(
        totalBirdsPlaced: totalBirdsPlaced,
        totalBirdsSold: totalBirdsSold,
        totalBirdsAlive: totalBirdsAlive,
        totalBirdsDead: totalBirdsDead,
        expenseMix: expenseMix,
        topBatch: topBatch,
        weakestBatch: weakestBatch,
      ),
    );
  }
}
