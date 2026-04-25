import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/batch_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/mortality_repository.dart';
import '../../data/repositories/growth_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/shed_repository.dart';
import '../../services/calculation_engine.dart';
import '../../services/pdf_service.dart';

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
