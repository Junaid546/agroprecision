import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/batch_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/mortality_repository.dart';
import '../../data/repositories/growth_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/shed_repository.dart';
import '../../data/repositories/shed_environment_repository.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/inventory_transaction_repository.dart';
import '../../data/repositories/health_treatment_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../services/calculation_engine.dart';
import '../../services/pdf_service.dart';
import '../../services/farm_preferences_service.dart';
import '../../services/security_service.dart';
import '../../services/inventory_flow_service.dart';
import '../../services/shed_operations_service.dart';
import '../../services/backup_restore_service.dart';
import '../../services/csv_export_service.dart';

// Repository providers — singleton instances
final farmRepositoryProvider =
    Provider<FarmRepository>((ref) => FarmRepository());
final batchRepositoryProvider =
    Provider<BatchRepository>((ref) => BatchRepository());
final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ExpenseRepository());
final mortalityRepositoryProvider =
    Provider<MortalityRepository>((ref) => MortalityRepository());
final growthRepositoryProvider =
    Provider<GrowthRepository>((ref) => GrowthRepository());
final saleRepositoryProvider =
    Provider<SaleRepository>((ref) => SaleRepository());
final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository());
final shedRepositoryProvider =
    Provider<ShedRepository>((ref) => ShedRepository());
final shedEnvironmentRepositoryProvider =
    Provider<ShedEnvironmentRepository>((ref) => ShedEnvironmentRepository());
final inventoryRepositoryProvider =
    Provider<InventoryRepository>((ref) => InventoryRepository());
final inventoryTransactionRepositoryProvider =
    Provider<InventoryTransactionRepository>(
        (ref) => InventoryTransactionRepository());
final healthTreatmentRepositoryProvider =
    Provider<HealthTreatmentRepository>((ref) => HealthTreatmentRepository());
final staffRepositoryProvider =
    Provider<StaffRepository>((ref) => StaffRepository());
final pdfServiceProvider =
    Provider<PDFService>((ref) => const DefaultPDFService());

// Calculation engine provider
final calculationEngineProvider = Provider<CalculationEngine>((ref) {
  return CalculationEngine(
    expenseRepo: ref.watch(expenseRepositoryProvider),
    mortalityRepo: ref.watch(mortalityRepositoryProvider),
    saleRepo: ref.watch(saleRepositoryProvider),
    growthRepo: ref.watch(growthRepositoryProvider),
    batchRepo: ref.watch(batchRepositoryProvider),
  );
});

final farmPreferencesServiceProvider =
    Provider<FarmPreferencesService>((ref) => FarmPreferencesService(ref));

final securityServiceProvider =
    Provider<SecurityService>((ref) => SecurityService());

final inventoryFlowServiceProvider = Provider<InventoryFlowService>((ref) {
  return InventoryFlowService(
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
  );
});

final shedOperationsServiceProvider = Provider<ShedOperationsService>((ref) {
  return ShedOperationsService(
    shedRepository: ref.watch(shedRepositoryProvider),
    environmentRepository: ref.watch(shedEnvironmentRepositoryProvider),
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    healthTreatmentRepository: ref.watch(healthTreatmentRepositoryProvider),
  );
});

final backupRestoreServiceProvider =
    Provider<BackupRestoreService>((ref) => BackupRestoreService());

final csvExportServiceProvider = Provider<CSVExportService>((ref) {
  return CSVExportService(
    batchRepository: ref.watch(batchRepositoryProvider),
    expenseRepository: ref.watch(expenseRepositoryProvider),
    mortalityRepository: ref.watch(mortalityRepositoryProvider),
    growthRepository: ref.watch(growthRepositoryProvider),
    saleRepository: ref.watch(saleRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    inventoryTransactionRepository:
        ref.watch(inventoryTransactionRepositoryProvider),
    healthTreatmentRepository: ref.watch(healthTreatmentRepositoryProvider),
    shedEnvironmentRepository: ref.watch(shedEnvironmentRepositoryProvider),
  );
});
