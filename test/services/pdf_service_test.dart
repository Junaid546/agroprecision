import 'dart:convert';

import 'package:agro_precision/data/models/batch_model.dart';
import 'package:agro_precision/data/models/expense_model.dart';
import 'package:agro_precision/data/models/farm_model.dart';
import 'package:agro_precision/data/models/growth_model.dart';
import 'package:agro_precision/data/models/mortality_model.dart';
import 'package:agro_precision/data/models/sale_model.dart';
import 'package:agro_precision/features/reports/models/report_models.dart';
import 'package:agro_precision/services/calculation_engine.dart';
import 'package:agro_precision/services/pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultPDFService', () {
    const service = DefaultPDFService();

    testWidgets('builds PDF bytes for a populated report', (tester) async {
      final report = _buildReportPayload();

      final bytes = await service.buildFinancialReportBytes(report: report);

      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.take(5).toList()), equals('%PDF-'));
    });

    testWidgets('builds PDF bytes when optional fields are missing',
        (tester) async {
      final report = _buildReportPayload(
        farm: FarmModel(
          id: 'farm-2',
          name: 'Lean Farm',
          ownerName: 'Owner',
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 1),
        ),
        batchDetails: const [],
        performanceRows: const [],
        summary: FarmSummaryFinancials(
          totalProfit: 0,
          totalRevenue: 0,
          totalCost: 0,
          overallROI: 0,
          batchCount: 0,
          avgCostPerBird: 0,
        ),
      );

      final bytes = await service.buildFinancialReportBytes(report: report);

      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.take(5).toList()), equals('%PDF-'));
    });

    test('sanitizes filename characters and includes timestamp', () {
      final filename = service.buildFinancialReportFilename(
        farmName: 'Green / Farm:* 01',
        generatedAt: DateTime(2026, 4, 25, 9, 45),
      );

      expect(filename, equals('Green___Farm___01_Report_20260425_0945.pdf'));
    });
  });
}

ReportExportPayload _buildReportPayload({
  FarmModel? farm,
  List<ReportBatchDetail>? batchDetails,
  List<BatchPerformanceRow>? performanceRows,
  FarmSummaryFinancials? summary,
}) {
  final resolvedFarm = farm ??
      FarmModel(
        id: 'farm-1',
        name: 'Agro Vision Farm',
        ownerName: 'Amina Khan',
        location: 'Lahore',
        phone: '0300-0000000',
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      );

  final batch = BatchModel(
    id: 'batch-1',
    shedId: 'shed-1',
    farmId: resolvedFarm.id,
    batchNumber: 'BT-001',
    initialCount: 5000,
    initialCostPerBird: 0.9,
    startDate: DateTime(2026, 3, 1),
    endDate: DateTime(2026, 4, 18),
    status: BatchStatus.completed,
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 4, 18),
    breed: 'Ross 308',
    targetWeightKg: 2.2,
    targetDays: 42,
  );

  final performance = BatchPerformanceRow(
    batchId: batch.id,
    batchNumber: batch.batchNumber,
    startDate: batch.startDate,
    endDate: batch.endDate,
    revenue: 16500,
    costs: 9800,
    netProfit: 6700,
    roi: 68.4,
  );

  final financials = BatchFinancials(
    batchId: batch.id,
    initialCount: 5000,
    initialCostPerBird: 0.9,
    totalExpenses: 5300,
    totalRevenue: 16500,
    totalMortality: 140,
    currentAlive: 3860,
    totalSold: 1000,
    latestWeightKg: 2.05,
    categoryBreakdown: const {
      ExpenseCategory.feed: 3200,
      ExpenseCategory.medication: 600,
      ExpenseCategory.labor: 900,
      ExpenseCategory.utilities: 400,
      ExpenseCategory.other: 200,
    },
    status: BatchStatus.completed,
  );

  final details = batchDetails ??
      [
        ReportBatchDetail(
          batch: batch,
          financials: financials,
          performance: performance,
          recentExpenses: [
            ExpenseModel(
              id: 'expense-1',
              batchId: batch.id,
              farmId: resolvedFarm.id,
              category: ExpenseCategory.feed,
              amount: 1200,
              description: 'Starter feed',
              date: DateTime(2026, 3, 8),
              createdAt: DateTime(2026, 3, 8),
            ),
          ],
          recentSales: [
            SaleModel(
              id: 'sale-1',
              batchId: batch.id,
              farmId: resolvedFarm.id,
              birdsSold: 1000,
              pricePerKg: 2.4,
              averageWeightKg: 2.1,
              totalRevenue: 5040,
              saleDate: DateTime(2026, 4, 18),
              createdAt: DateTime(2026, 4, 18),
            ),
          ],
          recentMortality: [
            MortalityModel(
              id: 'mortality-1',
              batchId: batch.id,
              farmId: resolvedFarm.id,
              count: 14,
              date: DateTime(2026, 3, 12),
              cause: 'Heat stress',
              createdAt: DateTime(2026, 3, 12),
            ),
          ],
          recentGrowth: [
            GrowthModel(
              id: 'growth-1',
              batchId: batch.id,
              farmId: resolvedFarm.id,
              averageWeightKg: 2.05,
              sampleSize: 40,
              batchDay: 40,
              date: DateTime(2026, 4, 10),
              feedConsumedKg: 3.5,
              createdAt: DateTime(2026, 4, 10),
            ),
          ],
        ),
      ];

  final rows = performanceRows ?? [performance];
  final resolvedSummary = summary ??
      FarmSummaryFinancials(
        totalProfit: 6700,
        totalRevenue: 16500,
        totalCost: 9800,
        overallROI: 68.4,
        batchCount: rows.length,
        avgCostPerBird: 2.02,
      );

  return ReportExportPayload(
    farm: resolvedFarm,
    farmName: resolvedFarm.name,
    ownerName: resolvedFarm.ownerName,
    location: resolvedFarm.location,
    phone: resolvedFarm.phone,
    generatedAt: DateTime(2026, 4, 25, 9, 30),
    summary: resolvedSummary,
    batchPerformanceRows: rows,
    batches: details,
    insights: const ReportFarmInsights(
      totalBirdsPlaced: 5000,
      totalBirdsSold: 1000,
      totalBirdsAlive: 3860,
      totalBirdsDead: 140,
      expenseMix: {
        ExpenseCategory.feed: 3200,
        ExpenseCategory.medication: 600,
      },
      topBatch: ReportBatchHighlight(
        batchNumber: 'BT-001',
        netProfit: 6700,
        roi: 68.4,
        status: BatchStatus.completed,
      ),
      weakestBatch: ReportBatchHighlight(
        batchNumber: 'BT-001',
        netProfit: 6700,
        roi: 68.4,
        status: BatchStatus.completed,
      ),
    ),
  );
}
