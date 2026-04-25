import '../data/repositories/batch_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/growth_repository.dart';
import '../data/repositories/health_treatment_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/inventory_transaction_repository.dart';
import '../data/repositories/mortality_repository.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/shed_environment_repository.dart';
import '../data/repositories/task_repository.dart';

class CSVExportService {
  final BatchRepository batchRepository;
  final ExpenseRepository expenseRepository;
  final MortalityRepository mortalityRepository;
  final GrowthRepository growthRepository;
  final SaleRepository saleRepository;
  final TaskRepository taskRepository;
  final InventoryRepository inventoryRepository;
  final InventoryTransactionRepository inventoryTransactionRepository;
  final HealthTreatmentRepository healthTreatmentRepository;
  final ShedEnvironmentRepository shedEnvironmentRepository;

  CSVExportService({
    required this.batchRepository,
    required this.expenseRepository,
    required this.mortalityRepository,
    required this.growthRepository,
    required this.saleRepository,
    required this.taskRepository,
    required this.inventoryRepository,
    required this.inventoryTransactionRepository,
    required this.healthTreatmentRepository,
    required this.shedEnvironmentRepository,
  });

  Future<String> buildFarmCsv(String farmId, {List<String> shedIds = const []}) async {
    final buffer = StringBuffer();
    buffer.writeln('section,id,primary,date,value1,value2,notes');

    final batches = await batchRepository.getByFarm(farmId);
    for (final batch in batches) {
      buffer.writeln(
          'batches,${batch.id},${_sanitize(batch.batchNumber)},${batch.startDate.toIso8601String()},${batch.initialCount},${batch.status.name},${_sanitize(batch.notes ?? '')}');
      final expenses = await expenseRepository.getByBatch(batch.id);
      for (final expense in expenses) {
        buffer.writeln(
            'expenses,${expense.id},${expense.category.name},${expense.date.toIso8601String()},${expense.amount},${expense.quantity ?? ''},${_sanitize(expense.description)}');
      }
      final mortality = await mortalityRepository.getByBatch(batch.id);
      for (final item in mortality) {
        buffer.writeln(
            'mortality,${item.id},${_sanitize(item.cause ?? 'Unknown')},${item.date.toIso8601String()},${item.count},,');
      }
      final growth = await growthRepository.getByBatch(batch.id);
      for (final item in growth) {
        buffer.writeln(
            'growth,${item.id},day_${item.batchDay},${item.date.toIso8601String()},${item.averageWeightKg},${item.feedConsumedKg ?? ''},${_sanitize(item.notes ?? '')}');
      }
      final sales = await saleRepository.getByBatch(batch.id);
      for (final sale in sales) {
        buffer.writeln(
            'sales,${sale.id},${_sanitize(sale.buyerName ?? 'Buyer')},${sale.saleDate.toIso8601String()},${sale.birdsSold},${sale.totalRevenue},');
      }
    }

    final tasks = await taskRepository.getByDate(DateTime.now());
    for (final task in tasks.where((task) => task.farmId == farmId)) {
      buffer.writeln(
          'tasks,${task.id},${_sanitize(task.title)},${task.scheduledDate.toIso8601String()},${task.priority.name},${task.status.name},${_sanitize(task.description ?? '')}');
    }

    final inventoryItems = await inventoryRepository.getByFarm(farmId);
    for (final item in inventoryItems) {
      buffer.writeln(
          'inventory_items,${item.id},${_sanitize(item.name)},${item.updatedAt.toIso8601String()},${item.quantity},${item.reorderLevel},${item.category.name}');
    }

    final transactions = await inventoryTransactionRepository.getByFarm(farmId);
    for (final transaction in transactions) {
      buffer.writeln(
          'inventory_transactions,${transaction.id},${transaction.type.name},${transaction.date.toIso8601String()},${transaction.quantityChange},${_sanitize(transaction.unit)},${_sanitize(transaction.notes ?? '')}');
    }

    final treatments = await healthTreatmentRepository.getByFarm(farmId);
    for (final treatment in treatments) {
      buffer.writeln(
          'treatments,${treatment.id},${treatment.type.name},${treatment.scheduledDate.toIso8601String()},${treatment.quantityUsed ?? ''},${treatment.isCompleted},${_sanitize(treatment.title)}');
    }

    for (final shedId in shedIds) {
      final readings = await shedEnvironmentRepository.getByShed(shedId);
      for (final reading in readings) {
        buffer.writeln(
            'environment_readings,${reading.id},${reading.shedId},${reading.recordedAt.toIso8601String()},${reading.temperatureC},${reading.humidityPercent},${_sanitize(reading.notes ?? '')}');
      }
    }

    return buffer.toString();
  }

  String _sanitize(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}
