import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agro_precision/data/models/batch_model.dart';
import 'package:agro_precision/data/repositories/batch_repository.dart';
import 'package:agro_precision/data/repositories/expense_repository.dart';
import 'package:agro_precision/data/repositories/growth_repository.dart';
import 'package:agro_precision/data/repositories/mortality_repository.dart';
import 'package:agro_precision/data/repositories/sale_repository.dart';
import 'package:agro_precision/services/calculation_engine.dart';

class MockBatchRepository extends Mock implements BatchRepository {}

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockMortalityRepository extends Mock implements MortalityRepository {}

class MockGrowthRepository extends Mock implements GrowthRepository {}

class MockSaleRepository extends Mock implements SaleRepository {}

void main() {
  late CalculationEngine engine;
  late MockBatchRepository mockBatchRepo;
  late MockExpenseRepository mockExpenseRepo;
  late MockMortalityRepository mockMortalityRepo;
  late MockGrowthRepository mockGrowthRepo;
  late MockSaleRepository mockSaleRepo;

  setUp(() {
    mockBatchRepo = MockBatchRepository();
    mockExpenseRepo = MockExpenseRepository();
    mockMortalityRepo = MockMortalityRepository();
    mockGrowthRepo = MockGrowthRepository();
    mockSaleRepo = MockSaleRepository();

    engine = CalculationEngine(
      batchRepo: mockBatchRepo,
      expenseRepo: mockExpenseRepo,
      mortalityRepo: mockMortalityRepo,
      growthRepo: mockGrowthRepo,
      saleRepo: mockSaleRepo,
    );
  });

  group('BatchFinancials Calculations', () {
    test('mortalityRate is exactly (deaths/initial)*100', () {
      final financials = BatchFinancials(
        batchId: 'test',
        initialCount: 1000,
        initialCostPerBird: 1.0,
        totalExpenses: 500,
        totalRevenue: 2000,
        totalMortality: 50,
        currentAlive: 950,
        totalSold: 0,
        categoryBreakdown: {},
        status: BatchStatus.active,
      );

      expect(financials.mortalityRate, 5.0);
    });

    test('roi is exactly (netProfit/totalCost)*100', () {
      // purchaseCost = 1000 * 1 = 1000
      // totalCost = 1000 + 500 = 1500
      // netProfit = 3000 - 1500 = 1500
      // roi = (1500 / 1500) * 100 = 100%
      final financials = BatchFinancials(
        batchId: 'test',
        initialCount: 1000,
        initialCostPerBird: 1.0,
        totalExpenses: 500,
        totalRevenue: 3000,
        totalMortality: 0,
        currentAlive: 1000,
        totalSold: 1000,
        categoryBreakdown: {},
        status: BatchStatus.completed,
      );

      expect(financials.roi, 100.0);
    });

    test('costPerBird accounts for mortality correctly', () {
      // totalCost = (1000 * 1) + 500 = 1500
      // alive = 1000 - 500 = 500
      // costPerBird = 1500 / 500 = 3.0
      final financials = BatchFinancials(
        batchId: 'test',
        initialCount: 1000,
        initialCostPerBird: 1.0,
        totalExpenses: 500,
        totalRevenue: 0,
        totalMortality: 500,
        currentAlive: 500,
        totalSold: 0,
        categoryBreakdown: {},
        status: BatchStatus.active,
      );

      expect(financials.costPerBird, 3.0);
    });

    test('breakEvenPricePerKg formula is correct', () {
      // totalCost = 1000
      // totalWeight = 500 birds * 2kg = 1000kg
      // breakeven = 1000 / 1000 = 1.0
      final financials = BatchFinancials(
        batchId: 'test',
        initialCount: 500,
        initialCostPerBird: 1.0,
        totalExpenses: 500,
        totalRevenue: 0,
        totalMortality: 0,
        currentAlive: 500,
        totalSold: 0,
        latestWeightKg: 2.0,
        categoryBreakdown: {},
        status: BatchStatus.active,
      );

      expect(financials.breakEvenPricePerKg, 1.0);
    });
  });

  group('CalculationEngine Methods', () {
    test('computeForBatch gathers data correctly from repos', () async {
      const batchId = 'batch-123';
      final batch = BatchModel(
        id: batchId,
        shedId: 'shed-1',
        farmId: 'farm-1',
        batchNumber: 'B1',
        initialCount: 100,
        initialCostPerBird: 2.0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: BatchStatus.active,
      );

      when(() => mockBatchRepo.getById(batchId)).thenAnswer((_) async => batch);
      when(() => mockExpenseRepo.getTotalForBatch(batchId))
          .thenAnswer((_) async => 150.0);
      when(() => mockSaleRepo.getTotalRevenueForBatch(batchId))
          .thenAnswer((_) async => 500.0);
      when(() => mockSaleRepo.getTotalSoldForBatch(batchId))
          .thenAnswer((_) async => 50);
      when(() => mockMortalityRepo.getTotalForBatch(batchId))
          .thenAnswer((_) async => 5);
      when(() => mockGrowthRepo.getLatest(batchId))
          .thenAnswer((_) async => null);
      when(() => mockExpenseRepo.getCategoryBreakdown(batchId))
          .thenAnswer((_) async => {});

      final result = await engine.computeForBatch(batchId);

      expect(result.batchId, batchId);
      expect(result.purchaseCost, 200.0);
      expect(result.totalCost, 350.0);
      expect(result.netProfit, 150.0);
    });
  });
}
