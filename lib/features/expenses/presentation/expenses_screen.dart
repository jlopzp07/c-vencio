import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:c_vencio/features/expenses/presentation/expenses_provider.dart';

class ExpensesScreen extends ConsumerWidget {
  final String vehicleId;

  const ExpensesScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vehicle-details/add-expense', extra: vehicleId),
          ),
        ],
      ),
      body: expensesState.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Text(
                'No expenses recorded.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(_getIconForCategory(expense.category), color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                title: Text(expense.category),
                subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Fuel': return Icons.local_gas_station;
      case 'Maintenance': return Icons.build;
      case 'Taxes': return Icons.attach_money;
      case 'Parking': return Icons.local_parking;
      case 'Washing': return Icons.local_car_wash;
      default: return Icons.receipt;
    }
  }
}
