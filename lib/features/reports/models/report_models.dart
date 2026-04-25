import 'dart:typed_data';

import '../../../data/models/batch_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/farm_model.dart';
import '../../../data/models/growth_model.dart';
import '../../../data/models/mortality_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../services/calculation_engine.dart';

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

class ReportPreviewArgs {
  final Uint8List bytes;
  final String filename;

  const ReportPreviewArgs({
    required this.bytes,
    required this.filename,
  });
}

class ReportBatchHighlight {
  final String batchNumber;
  final double netProfit;
  final double roi;
  final BatchStatus status;

  const ReportBatchHighlight({
    required this.batchNumber,
    required this.netProfit,
    required this.roi,
    required this.status,
  });
}

class ReportFarmInsights {
  final int totalBirdsPlaced;
  final int totalBirdsSold;
  final int totalBirdsAlive;
  final int totalBirdsDead;
  final Map<ExpenseCategory, double> expenseMix;
  final ReportBatchHighlight? topBatch;
  final ReportBatchHighlight? weakestBatch;

  const ReportFarmInsights({
    required this.totalBirdsPlaced,
    required this.totalBirdsSold,
    required this.totalBirdsAlive,
    required this.totalBirdsDead,
    required this.expenseMix,
    required this.topBatch,
    required this.weakestBatch,
  });
}

class ReportBatchDetail {
  final BatchModel batch;
  final BatchFinancials financials;
  final BatchPerformanceRow performance;
  final List<ExpenseModel> recentExpenses;
  final List<SaleModel> recentSales;
  final List<MortalityModel> recentMortality;
  final List<GrowthModel> recentGrowth;

  const ReportBatchDetail({
    required this.batch,
    required this.financials,
    required this.performance,
    required this.recentExpenses,
    required this.recentSales,
    required this.recentMortality,
    required this.recentGrowth,
  });
}

class ReportExportPayload {
  final FarmModel? farm;
  final String farmName;
  final String ownerName;
  final String? location;
  final String? phone;
  final DateTime generatedAt;
  final FarmSummaryFinancials summary;
  final List<BatchPerformanceRow> batchPerformanceRows;
  final List<ReportBatchDetail> batches;
  final ReportFarmInsights insights;

  const ReportExportPayload({
    required this.farm,
    required this.farmName,
    required this.ownerName,
    required this.location,
    required this.phone,
    required this.generatedAt,
    required this.summary,
    required this.batchPerformanceRows,
    required this.batches,
    required this.insights,
  });

  bool get hasBatches => batchPerformanceRows.isNotEmpty;
}
