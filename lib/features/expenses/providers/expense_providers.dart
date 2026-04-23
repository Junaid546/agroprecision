import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../features/batch/providers/batch_providers.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';

// Expenses for current selected batch
final expenseListProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, batchId) async {
  return ref.watch(expenseRepositoryProvider).getByBatch(batchId);
});

// Expense category breakdown for chart
final expenseCategoryBreakdownProvider =
    FutureProvider.family<Map<ExpenseCategory, double>, String>(
        (ref, batchId) async {
  return ref.watch(expenseRepositoryProvider).getCategoryBreakdown(batchId);
});

// Expense entry form notifier
final expenseFormNotifier =
    StateNotifierProvider<ExpenseFormNotifier, ExpenseFormState>((ref) {
  return ExpenseFormNotifier(ref.watch(expenseRepositoryProvider), ref);
});

class ExpenseFormState {
  final bool isLoading;
  final String? error;
  final bool success;
  ExpenseFormState({this.isLoading = false, this.error, this.success = false});
}

class ExpenseFormNotifier extends StateNotifier<ExpenseFormState> {
  ExpenseFormNotifier(this._repo, this._ref) : super(ExpenseFormState());
  final ExpenseRepository _repo;
  final Ref _ref;

  Future<void> submit(ExpenseModel expense) async {
    state = ExpenseFormState(isLoading: true);
    try {
      await _repo.create(expense);
      _ref.invalidate(expenseListProvider(expense.batchId));
      _ref.invalidate(batchFinancialsProvider(expense.batchId));
      _ref.invalidate(farmSummaryProvider);
      state = ExpenseFormState(success: true);
    } catch (e) {
      state = ExpenseFormState(error: e.toString());
    }
  }
}
