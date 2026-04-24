import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:agro_precision/services/calculation_engine.dart';
import 'package:agro_precision/data/models/batch_model.dart';
import 'package:agro_precision/data/models/expense_model.dart';
import 'package:agro_precision/data/models/mortality_model.dart';
import 'package:agro_precision/data/models/growth_model.dart';
import 'package:agro_precision/data/models/sale_model.dart';
import 'package:agro_precision/data/repositories/batch_repository.dart';
import 'package:agro_precision/data/repositories/expense_repository.dart';
import 'package:agro_precision/data/repositories/mortality_repository.dart';
import 'package:agro_precision/data/repositories/growth_repository.dart';
import 'package:agro_precision/data/repositories/sale_repository.dart';
import 'package:agro_precision/services/hive_service.dart';

void main() {
  late CalculationEngine engine;
  late BatchRepository batchRepo;
  late ExpenseRepository expenseRepo;
  late MortalityRepository mortalityRepo;
  late SaleRepository saleRepo;
  late GrowthRepository growthRepo;

  Future<void> setupHive() async {
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(BatchStatusAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(ExpenseCategoryAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BatchModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExpenseModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(MortalityModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(GrowthModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SaleModelAdapter());

    // Open boxes
    await Hive.openBox<BatchModel>(HiveService.batchBoxName);
    await Hive.openBox<ExpenseModel>(HiveService.expenseBoxName);
    await Hive.openBox<MortalityModel>(HiveService.mortalityBoxName);
    await Hive.openBox<GrowthModel>(HiveService.growthBoxName);
    await Hive.openBox<SaleModel>(HiveService.saleBoxName);
  }

  setUp(() async {
    await setupHive();
    batchRepo = BatchRepository();
    expenseRepo = ExpenseRepository();
    mortalityRepo = MortalityRepository();
    saleRepo = SaleRepository();
    growthRepo = GrowthRepository();
    engine = CalculationEngine(
      expenseRepo: expenseRepo,
      mortalityRepo: mortalityRepo,
      saleRepo: saleRepo,
      growthRepo: growthRepo,
      batchRepo: batchRepo,
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  group('Batch Lifecycle', () {
    test('Create batch → verify it appears in batch list', () async {
      final batch = BatchModel.create(
        farmId: 'farm-1',
        shedId: 'shed-1',
        batchNumber: 'BT-001',
        initialCount: 5000,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);
      
      final all = await batchRepo.getAll();
      expect(all.any((b) => b.batchNumber == 'BT-001'), isTrue);
    });

    test('Add expense → verify total expenses updates', () async {
       final batch = BatchModel.create(
        farmId: 'farm-1',
        shedId: 'shed-1',
        batchNumber: 'BT-002',
        initialCount: 5000,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);

      final expense = ExpenseModel.create(
        batchId: batch.id,
        farmId: 'farm-1',
        category: ExpenseCategory.feed,
        amount: 500.0,
        description: 'Feed',
        date: DateTime.now(),
      );
      await expenseRepo.create(expense);
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.totalExpenses, 500.0);
    });

    test('Log mortality → verify alive count decreases', () async {
       final batch = BatchModel.create(
        farmId: 'farm-1',
        shedId: 'shed-1',
        batchNumber: 'BT-003',
        initialCount: 100,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);

      await mortalityRepo.create(MortalityModel.create(
        batchId: batch.id,
        farmId: 'farm-1',
        count: 5,
        date: DateTime.now(),
      ));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.currentAlive, 95);
    });

    test('Record growth → verify growth record exists', () async {
      final batch = BatchModel.create(
        farmId: 'farm-1',
        shedId: 'shed-1',
        batchNumber: 'BT-004',
        initialCount: 100,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);

      await growthRepo.create(GrowthModel.create(
        batchId: batch.id,
        farmId: 'farm-1',
        averageWeightKg: 1.2,
        sampleSize: 10,
        batchDay: 14,
        date: DateTime.now(),
      ));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.latestWeightKg, 1.2);
    });

    test('Add sale → verify revenue and profit update', () async {
      final batch = BatchModel.create(
        farmId: 'farm-1',
        shedId: 'shed-1',
        batchNumber: 'BT-005',
        initialCount: 100,
        initialCostPerBird: 1.0, // Cost = 100
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);

      await saleRepo.create(SaleModel.create(
        batchId: batch.id,
        farmId: 'farm-1',
        birdsSold: 100,
        averageWeightKg: 1.5,
        pricePerKg: 2.0, // Revenue = 300
        saleDate: DateTime.now(),
      ));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.totalRevenue, 300.0);
      expect(f.netProfit, 200.0);
    });
  });

  group('Calculation Accuracy', () {
    test('Mortality rate: 100 deaths / 5000 initial = 2.0%', () async {
      final batch = BatchModel.create(
        farmId: 'f',
        shedId: 's',
        batchNumber: 'MORT',
        initialCount: 5000,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);
      await mortalityRepo.create(MortalityModel.create(batchId: batch.id, farmId: 'f', count: 100, date: DateTime.now()));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.mortalityRate, 2.0);
    });

    test('ROI: (500 profit / 1000 cost) * 100 = 50.0%', () async {
      final batch = BatchModel.create(
        farmId: 'f',
        shedId: 's',
        batchNumber: 'ROI',
        initialCount: 1000,
        initialCostPerBird: 1.0, // Cost = 1000
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);
      
      await saleRepo.create(SaleModel.create(
        batchId: batch.id,
        farmId: 'f',
        birdsSold: 1000,
        averageWeightKg: 1.0,
        pricePerKg: 1.5, // Revenue = 1500, Profit = 500
        saleDate: DateTime.now(),
      ));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.roi, 50.0);
    });

    test('Cost per bird: 1000 total cost / 4900 surviving birds = 0.204', () async {
      final batch = BatchModel.create(
        farmId: 'f',
        shedId: 's',
        batchNumber: 'CPB',
        initialCount: 5000,
        initialCostPerBird: 0.2, // Cost = 1000
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);
      await mortalityRepo.create(MortalityModel.create(batchId: batch.id, farmId: 'f', count: 100, date: DateTime.now()));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.costPerBird, closeTo(0.20408, 0.0001));
    });

    test('Break-even price: 1000 cost / (4900 birds * 1.9 kg) = 0.1075 USD/kg', () async {
      final batch = BatchModel.create(
        farmId: 'f',
        shedId: 's',
        batchNumber: 'BEP',
        initialCount: 5000,
        initialCostPerBird: 0.2, // Cost = 1000
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);
      await mortalityRepo.create(MortalityModel.create(batchId: batch.id, farmId: 'f', count: 100, date: DateTime.now()));
      await growthRepo.create(GrowthModel.create(
        batchId: batch.id,
        farmId: 'f',
        averageWeightKg: 1.9,
        sampleSize: 10,
        batchDay: 40,
        date: DateTime.now(),
      ));
      
      final f = await engine.computeForBatch(batch.id);
      expect(f.breakEvenPricePerKg, closeTo(0.10741, 0.00001));
    });
  });

  group('Decision Engine', () {
    test('Alert triggers based on thresholds', () async {
      final batch = BatchModel.create(
        farmId: 'f',
        shedId: 's',
        batchNumber: 'ALERTS',
        initialCount: 5000,
        initialCostPerBird: 0.5,
        startDate: DateTime.now(),
      );
      await batchRepo.create(batch);

      // No alert when mortality < 1%
      await mortalityRepo.create(MortalityModel.create(batchId: batch.id, farmId: 'f', count: 10, date: DateTime.now()));
      var alerts = await engine.analyzeAndAlert(batch.id);
      expect(alerts.any((a) => a.metric == 'mortality'), isFalse);

      // Alert fires when daily mortality > 1% (50 birds)
      await mortalityRepo.create(MortalityModel.create(batchId: batch.id, farmId: 'f', count: 41, date: DateTime.now())); // total 51
      alerts = await engine.analyzeAndAlert(batch.id);
      expect(alerts.any((a) => a.metric == 'mortality'), isTrue);

      // FCR warning fires when FCR > 2.0
      await growthRepo.create(GrowthModel.create(
        batchId: batch.id,
        farmId: 'f',
        averageWeightKg: 1.0,
        feedConsumedKg: 2.5, // FCR = 2.5
        sampleSize: 10,
        batchDay: 30,
        date: DateTime.now(),
      ));
      alerts = await engine.analyzeAndAlert(batch.id);
      expect(alerts.any((a) => a.metric == 'fcr'), isTrue);
    });
  });
}
