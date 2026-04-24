import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../services/hive_service.dart';
import '../../data/models/farm_model.dart';
import '../../data/models/shed_model.dart';
import '../../data/models/batch_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/mortality_model.dart';
import '../../data/models/growth_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/task_model.dart';

class SeedDataGenerator {
  static Future<void> seedDemoData() async {
    // 1. Clear existing data
    await HiveService.farmBox.clear();
    await HiveService.shedBox.clear();
    await HiveService.batchBox.clear();
    await HiveService.expenseBox.clear();
    await HiveService.mortalityBox.clear();
    await HiveService.growthBox.clear();
    await HiveService.saleBox.clear();
    await HiveService.taskBox.clear();

    // 2. Create Farm
    final farm = FarmModel(
      id: const Uuid().v4(),
      name: "Green Valley Farm",
      ownerName: "Ahmad Hassan",
      location: "Lahore, Punjab",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSetupComplete: true,
    );
    await HiveService.farmBox.put(farm.id, farm);

    // 3. Create Sheds
    final shedA = ShedModel(
      id: const Uuid().v4(),
      farmId: farm.id,
      name: "Block A",
      capacity: 5000,
      createdAt: DateTime.now(),
    );
    final shedB = ShedModel(
      id: const Uuid().v4(),
      farmId: farm.id,
      name: "Block B",
      capacity: 3000,
      createdAt: DateTime.now(),
    );
    await HiveService.shedBox.put(shedA.id, shedA);
    await HiveService.shedBox.put(shedB.id, shedB);

    // 4. Batch #204: Active, 28 days ago, 5000 birds, Block A
    final startDate204 = DateTime.now().subtract(const Duration(days: 28));
    final batch204 = BatchModel(
      id: const Uuid().v4(),
      farmId: farm.id,
      shedId: shedA.id,
      batchNumber: "204",
      initialCount: 5000,
      initialCostPerBird: 0.5,
      startDate: startDate204,
      status: BatchStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await HiveService.batchBox.put(batch204.id, batch204);

    // Expenses for #204: 28 daily feed records (~$450/day), 3 medications
    for (int i = 0; i < 28; i++) {
      final date = startDate204.add(Duration(days: i));
      final expense = ExpenseModel.create(
        batchId: batch204.id,
        farmId: farm.id,
        category: ExpenseCategory.feed,
        amount: 450.0 + (i * 2),
        description: "Daily Feed Day ${i + 1}",
        date: date,
      );
      await HiveService.expenseBox.put(expense.id, expense);
    }
    
    // medications
    final meds = [
      ExpenseModel.create(batchId: batch204.id, farmId: farm.id, category: ExpenseCategory.medication, amount: 150, description: "Vitamins", date: startDate204.add(const Duration(days: 1))),
      ExpenseModel.create(batchId: batch204.id, farmId: farm.id, category: ExpenseCategory.medication, amount: 200, description: "Antibiotics", date: startDate204.add(const Duration(days: 14))),
      ExpenseModel.create(batchId: batch204.id, farmId: farm.id, category: ExpenseCategory.medication, amount: 120, description: "Vitamins Boost", date: startDate204.add(const Duration(days: 21))),
    ];
    for (var m in meds) await HiveService.expenseBox.put(m.id, m);

    // Mortality for #204
    for (int i = 0; i < 28; i++) {
      final count = (i % 4 == 0) ? 3 : (i % 2 == 0 ? 1 : 0);
      if (count > 0) {
        final mort = MortalityModel.create(
          batchId: batch204.id,
          farmId: farm.id,
          count: count,
          date: startDate204.add(Duration(days: i)),
          cause: "Natural",
        );
        await HiveService.mortalityBox.put(mort.id, mort);
      }
    }

    // Growth for #204
    final growth204 = [
      GrowthModel.create(batchId: batch204.id, farmId: farm.id, averageWeightKg: 0.05, sampleSize: 1, batchDay: 1, date: startDate204.add(const Duration(days: 0))),
      GrowthModel.create(batchId: batch204.id, farmId: farm.id, averageWeightKg: 0.18, sampleSize: 1, batchDay: 7, date: startDate204.add(const Duration(days: 6))),
      GrowthModel.create(batchId: batch204.id, farmId: farm.id, averageWeightKg: 0.55, sampleSize: 1, batchDay: 14, date: startDate204.add(const Duration(days: 13))),
      GrowthModel.create(batchId: batch204.id, farmId: farm.id, averageWeightKg: 1.1, sampleSize: 1, batchDay: 21, date: startDate204.add(const Duration(days: 20))),
      GrowthModel.create(batchId: batch204.id, farmId: farm.id, averageWeightKg: 1.9, sampleSize: 1, batchDay: 28, date: startDate204.add(const Duration(days: 27))),
    ];
    for (var g in growth204) await HiveService.growthBox.put(g.id, g);

    // Batch #203: Completed
    final startDate203 = DateTime.now().subtract(const Duration(days: 90));
    final endDate203 = DateTime.now().subtract(const Duration(days: 55));
    final batch203 = BatchModel(
      id: const Uuid().v4(),
      farmId: farm.id,
      shedId: shedB.id,
      batchNumber: "203",
      initialCount: 5200,
      initialCostPerBird: 0.45,
      startDate: startDate203,
      endDate: endDate203,
      status: BatchStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await HiveService.batchBox.put(batch203.id, batch203);

    final mort203 = MortalityModel.create(batchId: batch203.id, farmId: farm.id, count: 98, date: startDate203.add(const Duration(days: 15)), cause: "Misc");
    await HiveService.mortalityBox.put(mort203.id, mort203);

    final sale203 = SaleModel.create(
      batchId: batch203.id,
      farmId: farm.id,
      birdsSold: 5102,
      averageWeightKg: 1.85,
      pricePerKg: 2.35,
      saleDate: endDate203,
      buyerName: "Local Market",
    );
    await HiveService.saleBox.put(sale203.id, sale203);

    // Batch #205: Active
    final startDate205 = DateTime.now().subtract(const Duration(days: 22));
    final batch205 = BatchModel(
      id: const Uuid().v4(),
      farmId: farm.id,
      shedId: shedA.id,
      batchNumber: "205",
      initialCount: 2500,
      initialCostPerBird: 0.52,
      startDate: startDate205,
      status: BatchStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await HiveService.batchBox.put(batch205.id, batch205);

    // Tasks for today
    final today = DateTime.now();
    final tasks = [
      TaskModel.create(farmId: farm.id, title: "Morning Feed", scheduledDate: today, scheduledTime: "06:00")..status = TaskStatus.done,
      TaskModel.create(farmId: farm.id, title: "Check Water Levels", scheduledDate: today, scheduledTime: "07:30", priority: TaskPriority.routine),
      TaskModel.create(farmId: farm.id, batchId: batch204.id, shedId: shedA.id, title: "Newcastle Vaccination Day 28", scheduledDate: today, scheduledTime: "09:00", priority: TaskPriority.priority),
      TaskModel.create(farmId: farm.id, title: "Litter Management", scheduledDate: today, scheduledTime: "14:00"),
    ];
    for (var t in tasks) await HiveService.taskBox.put(t.id, t);
    
    // Set active farm and batch in preferences
    final settings = Hive.box(HiveService.settingsBoxName);
    await settings.put('lastFarmId', farm.id);
    await settings.put('lastBatchId', batch204.id);
  }
}
