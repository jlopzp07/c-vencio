import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/features/expenses/domain/expense.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_provider.dart';
import 'package:vehicle_tracker/features/expenses/presentation/widgets/manual_expense_form.dart';

/// Pantalla de experiencia rápida para agregar gasto manualmente
class QuickManualExpenseScreen extends ConsumerWidget {
  final String vehicleId;

  const QuickManualExpenseScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Agregar Gasto Manual'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ManualExpenseForm(
          vehicleId: vehicleId,
          onSave: (expenseTemplate) => _saveManualExpense(context, ref, expenseTemplate),
        ),
      ),
    );
  }

  Future<void> _saveManualExpense(
    BuildContext context,
    WidgetRef ref,
    Expense expenseTemplate,
  ) async {
    try {
      // Crear expense con ID único
      final expense = Expense(
        id: const Uuid().v4(),
        vehicleId: expenseTemplate.vehicleId,
        category: expenseTemplate.category,
        amount: expenseTemplate.amount,
        date: expenseTemplate.date,
        description: expenseTemplate.description,
        parsedByAi: false,
      );

      await ref.addExpense(expense, vehicleId);

      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado exitosamente'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }
}
