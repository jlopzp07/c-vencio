import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/expenses/data/expense_repository.dart';
import 'package:vehicle_tracker/features/expenses/domain/expense.dart';

// Simple FutureProvider for fetching expenses
final expensesProvider = FutureProvider.autoDispose
    .family<List<Expense>, String>((ref, vehicleId) async {
      final repository = ref.read(expenseRepositoryProvider);
      return repository.getExpenses(vehicleId);
    });

// Helper methods for mutations
extension ExpensesMutations on WidgetRef {
  Future<void> addExpense(Expense expense, String vehicleId) async {
    final repository = read(expenseRepositoryProvider);
    await repository.addExpense(expense);
    invalidate(expensesProvider(vehicleId));
  }

  Future<void> deleteExpense(String id, String vehicleId) async {
    final repository = read(expenseRepositoryProvider);
    await repository.deleteExpense(id);
    invalidate(expensesProvider(vehicleId));
  }
}
