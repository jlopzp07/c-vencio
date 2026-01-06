import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:c_vencio/features/expenses/domain/expense.dart';

final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

class ExpenseRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses(String vehicleId) async {
    final response = await _supabase
        .from('expenses')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('date', ascending: false);
    
    return (response as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _supabase.from('expenses').insert(expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _supabase.from('expenses').delete().eq('id', id);
  }
}
