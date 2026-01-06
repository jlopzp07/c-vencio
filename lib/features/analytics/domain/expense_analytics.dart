import 'package:equatable/equatable.dart';

/// Estadísticas de gastos por categoría
class CategoryExpense extends Equatable {
  final String category;
  final double total;
  final int count;
  final double percentage;

  const CategoryExpense({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, total, count, percentage];
}

/// Análisis de gastos por período
class ExpenseAnalytics extends Equatable {
  final double total;
  final List<CategoryExpense> byCategory;
  final DateTime startDate;
  final DateTime endDate;
  final double averagePerDay;
  final String topCategory;

  const ExpenseAnalytics({
    required this.total,
    required this.byCategory,
    required this.startDate,
    required this.endDate,
    required this.averagePerDay,
    required this.topCategory,
  });

  @override
  List<Object?> get props => [
        total,
        byCategory,
        startDate,
        endDate,
        averagePerDay,
        topCategory,
      ];
}

/// Punto de datos para gráfica de tendencia mensual
class MonthlyExpenseData extends Equatable {
  final DateTime month;
  final double amount;
  final int expenseCount;

  const MonthlyExpenseData({
    required this.month,
    required this.amount,
    required this.expenseCount,
  });

  String get monthLabel {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month.month - 1];
  }

  @override
  List<Object?> get props => [month, amount, expenseCount];
}
