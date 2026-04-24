import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/farm_model.dart';
import '../../data/models/shed_model.dart';
import '../../data/models/batch_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/mortality_model.dart';
import '../../shared/providers/repository_providers.dart';
import '../../features/dashboard/providers/dashboard_providers.dart';
import '../../features/batch/providers/batch_providers.dart';

class SeedDataGenerator {
  static Future<void> seedDemoData(WidgetRef ref) async {
    final farmRepo = ref.read(farmRepositoryProvider);
    final shedRepo = ref.read(shedRepositoryProvider);
    final batchRepo = ref.read(batchRepositoryProvider);
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final mortalityRepo = ref.read(mortalityRepositoryProvider);

    // 1. Create Farm
    final farm = FarmModel.create(
      name: "Green Valley Farm",
      ownerName: "Ahmad Hassan",
      location: "Lahore, Punjab",
    );
    await farmRepo.create(farm);

    // 2. Create Sheds
    final shedA = ShedModel.create(
      farmId: farm.id,
      name: "Block A",
      capacity: 5000,
    );
    final shedB = ShedModel.create(
      farmId: farm.id,
      name: "Block B",
      capacity: 3000,
    );
    await shedRepo.create(shedA);
    await shedRepo.create(shedB);

    final now = DateTime.now();

    // 3. Batch #204: Active, started 28 days ago, 5000 initial, Block A
    final startDate204 = now.subtract(const Duration(days: 28));
    final batch204 = BatchModel.create(
      farmId: farm.id,
      shedId: shedA.id,
      batchNumber: "204",
      initialCount: 5000,
      initialCostPerBird: 0.85,
      breed: "Cobb 500",
      startDate: startDate204,
    )..status = BatchStatus.active;
    await batchRepo.create(batch204);

    // Seed 28 days of data for Batch 204
    for (int i = 0; i < 28; i++) {
      final date = startDate204.add(Duration(days: i));
      
      // Expenses (Feed: ~$450/d)
      await expenseRepo.create(ExpenseModel.create(
        batchId: batch204.id,
        farmId: farm.id,
        amount: 440.0 + (i % 5) * 10.0,
        category: ExpenseCategory.feed,
        description: "Daily Feed - Day ${i + 1}",
        date: date,
        quantity: 150.0,
        unit: "kg",
      ));

      // Mortality (avg 1-3 birds/d)
      if (i % 3 != 0) {
        await mortalityRepo.create(MortalityModel.create(
          batchId: batch204.id,
          farmId: farm.id,
          count: (i % 3) + 1,
          date: date,
          cause: "Normal",
        ));
      }
    }

    // 4. Batch #203: Completed, started 60 days ago, ended 10 days ago, 3000 birds
    final startDate203 = now.subtract(const Duration(days: 60));
    final endDate203 = now.subtract(const Duration(days: 10));
    final batch203 = BatchModel.create(
      farmId: farm.id,
      shedId: shedB.id,
      batchNumber: "203",
      initialCount: 3000,
      initialCostPerBird: 0.80,
      breed: "Ross 308",
      startDate: startDate203,
    );
    batch203.status = BatchStatus.completed;
    batch203.endDate = endDate203;
    await batchRepo.create(batch203);

    // 5. Batch #205: Just started (Day 1), 5000 birds
    final batch205 = BatchModel.create(
      farmId: farm.id,
      shedId: shedA.id,
      batchNumber: "205",
      initialCount: 5000,
      initialCostPerBird: 0.90,
      breed: "Cobb 500",
      startDate: now,
    );
    await batchRepo.create(batch205);

    // Refresh providers
    ref.invalidate(allBatchesProvider);
    ref.invalidate(dashboardSummaryProvider);
  }
}
