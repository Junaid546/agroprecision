import '../../services/hive_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  Future<ExpenseModel> create(ExpenseModel expense) async {
    await HiveService.expenseBox.put(expense.id, expense);
    return expense;
  }

  Future<List<ExpenseModel>> getByBatch(String batchId) async {
    return HiveService.getExpensesForBatch(batchId);
  }

  Future<List<ExpenseModel>> getByDateRange(
      String batchId, DateTime start, DateTime end) async {
    return HiveService.getExpensesForBatch(batchId)
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList();
  }

  Future<double> getTotalForBatch(String batchId) async {
    return HiveService.getExpensesForBatch(batchId)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<ExpenseCategory, double>> getCategoryBreakdown(
      String batchId) async {
    final expenses = HiveService.getExpensesForBatch(batchId);
    final Map<ExpenseCategory, double> breakdown = {};

    for (final e in expenses) {
      breakdown[e.category] = (breakdown[e.category] ?? 0.0) + e.amount;
    }
    return breakdown;
  }

  Future<ExpenseModel> update(ExpenseModel expense) async {
    await expense.save();
    return expense;
  }

  Future<void> delete(String id) async {
    await HiveService.expenseBox.delete(id);
  }
}
