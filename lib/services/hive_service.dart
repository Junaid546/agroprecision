import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/farm_model.dart';
import '../data/models/shed_model.dart';
import '../data/models/batch_model.dart';
import '../data/models/expense_model.dart';
import '../data/models/mortality_model.dart';
import '../data/models/growth_model.dart';
import '../data/models/sale_model.dart';
import '../data/models/task_model.dart';

class HiveService {
  // Box names
  static const String farmBoxName = 'farms';
  static const String shedBoxName = 'sheds';
  static const String batchBoxName = 'batches';
  static const String expenseBoxName = 'expenses';
  static const String mortalityBoxName = 'mortality_logs';
  static const String growthBoxName = 'growth_logs';
  static const String saleBoxName = 'sales';
  static const String taskBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  // Box getters
  static Box<FarmModel> get farmBox => Hive.box<FarmModel>(farmBoxName);
  static Box<ShedModel> get shedBox => Hive.box<ShedModel>(shedBoxName);
  static Box<BatchModel> get batchBox => Hive.box<BatchModel>(batchBoxName);
  static Box<ExpenseModel> get expenseBox => Hive.box<ExpenseModel>(expenseBoxName);
  static Box<MortalityModel> get mortalityBox => Hive.box<MortalityModel>(mortalityBoxName);
  static Box<GrowthModel> get growthBox => Hive.box<GrowthModel>(growthBoxName);
  static Box<SaleModel> get saleBox => Hive.box<SaleModel>(saleBoxName);
  static Box<TaskModel> get taskBox => Hive.box<TaskModel>(taskBoxName);

  static Future<void> init() async {
    // Enums FIRST (they are referenced by model adapters)
    if (!Hive.isAdapterRegistered(8))  Hive.registerAdapter(BatchStatusAdapter());
    if (!Hive.isAdapterRegistered(9))  Hive.registerAdapter(ExpenseCategoryAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(TaskPriorityAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(TaskStatusAdapter());

    // Models
    if (!Hive.isAdapterRegistered(0))  Hive.registerAdapter(FarmModelAdapter());
    if (!Hive.isAdapterRegistered(1))  Hive.registerAdapter(ShedModelAdapter());
    if (!Hive.isAdapterRegistered(2))  Hive.registerAdapter(BatchModelAdapter());
    if (!Hive.isAdapterRegistered(3))  Hive.registerAdapter(ExpenseModelAdapter());
    if (!Hive.isAdapterRegistered(4))  Hive.registerAdapter(MortalityModelAdapter());
    if (!Hive.isAdapterRegistered(5))  Hive.registerAdapter(GrowthModelAdapter());
    if (!Hive.isAdapterRegistered(6))  Hive.registerAdapter(SaleModelAdapter());
    if (!Hive.isAdapterRegistered(7))  Hive.registerAdapter(TaskModelAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<FarmModel>(farmBoxName),
      Hive.openBox<ShedModel>(shedBoxName),
      Hive.openBox<BatchModel>(batchBoxName),
      Hive.openBox<ExpenseModel>(expenseBoxName),
      Hive.openBox<MortalityModel>(mortalityBoxName),
      Hive.openBox<GrowthModel>(growthBoxName),
      Hive.openBox<SaleModel>(saleBoxName),
      Hive.openBox<TaskModel>(taskBoxName),
      Hive.openBox(settingsBoxName),
    ]);
  }

  // Box query helpers
  static List<ExpenseModel> getExpensesForBatch(String batchId) {
    return expenseBox.values
        .where((e) => e.batchId == batchId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<MortalityModel> getMortalityForBatch(String batchId) {
    return mortalityBox.values
        .where((m) => m.batchId == batchId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<GrowthModel> getGrowthForBatch(String batchId) {
    return growthBox.values
        .where((g) => g.batchId == batchId)
        .toList()
      ..sort((a, b) => a.batchDay.compareTo(b.batchDay));
  }

  static List<TaskModel> getTasksForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return taskBox.values
        .where((t) {
          final tDay = DateTime(t.scheduledDate.year, t.scheduledDate.month, t.scheduledDate.day);
          return tDay == day;
        })
        .toList()
      ..sort((a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''));
  }

  static List<TaskModel> getTasksForBatch(String batchId) {
    return taskBox.values.where((t) => t.batchId == batchId).toList();
  }

  // Backup: export all data to JSON Map
  static Map<String, dynamic> exportToJson() {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'farms': farmBox.values.map((f) => f.toJson()).toList(),
      'sheds': shedBox.values.map((s) => s.toJson()).toList(),
      'batches': batchBox.values.map((b) => b.toJson()).toList(),
      'expenses': expenseBox.values.map((e) => e.toJson()).toList(),
      'mortality': mortalityBox.values.map((m) => m.toJson()).toList(),
      'growth': growthBox.values.map((g) => g.toJson()).toList(),
      'sales': saleBox.values.map((s) => s.toJson()).toList(),
      'tasks': taskBox.values.map((t) => t.toJson()).toList(),
    };
  }
}
