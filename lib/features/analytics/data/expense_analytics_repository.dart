import 'package:c_vencio/features/analytics/domain/expense_analytics.dart';
import 'package:c_vencio/features/expenses/domain/expense.dart';

/// Repositorio para calcular analíticas de gastos
class ExpenseAnalyticsRepository {
  /// Calcula analytics para un período de tiempo
  ExpenseAnalytics calculateAnalytics(
    List<Expense> expenses, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (expenses.isEmpty) {
      return ExpenseAnalytics(
        total: 0,
        byCategory: const [],
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now(),
        averagePerDay: 0,
        topCategory: '',
      );
    }

    // Filtrar por fechas si se especifican
    var filteredExpenses = expenses;
    if (startDate != null) {
      filteredExpenses = filteredExpenses
          .where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate))
          .toList();
    }
    if (endDate != null) {
      filteredExpenses = filteredExpenses
          .where((e) => e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate))
          .toList();
    }

    if (filteredExpenses.isEmpty) {
      return ExpenseAnalytics(
        total: 0,
        byCategory: const [],
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now(),
        averagePerDay: 0,
        topCategory: '',
      );
    }

    // Calcular total
    final total = filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    // Agrupar por categoría
    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};

    for (final expense in filteredExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      categoryCounts[expense.category] =
          (categoryCounts[expense.category] ?? 0) + 1;
    }

    // Crear lista de CategoryExpense con porcentajes
    final byCategory = categoryTotals.entries.map((entry) {
      return CategoryExpense(
        category: entry.key,
        total: entry.value,
        count: categoryCounts[entry.key] ?? 0,
        percentage: total > 0 ? (entry.value / total) * 100 : 0,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total)); // Ordenar por total descendente

    // Calcular fechas de inicio y fin reales
    final dates = filteredExpenses.map((e) => e.date).toList()..sort();
    final actualStartDate = startDate ?? dates.first;
    final actualEndDate = endDate ?? dates.last;

    // Calcular promedio por día
    final daysDifference = actualEndDate.difference(actualStartDate).inDays + 1;
    final averagePerDay = daysDifference > 0 ? (total / daysDifference).toDouble() : 0.0;

    // Obtener categoría top
    final topCategory = byCategory.isNotEmpty ? byCategory.first.category : '';

    return ExpenseAnalytics(
      total: total,
      byCategory: byCategory,
      startDate: actualStartDate,
      endDate: actualEndDate,
      averagePerDay: averagePerDay,
      topCategory: topCategory,
    );
  }

  /// Calcula datos mensuales para los últimos N meses
  List<MonthlyExpenseData> calculateMonthlyTrend(
    List<Expense> expenses, {
    int months = 6,
  }) {
    if (expenses.isEmpty) return [];

    final now = DateTime.now();
    final monthlyData = <DateTime, List<Expense>>{};

    // Inicializar últimos N meses
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyData[month] = [];
    }

    // Agrupar gastos por mes
    for (final expense in expenses) {
      final monthKey = DateTime(expense.date.year, expense.date.month, 1);

      // Solo incluir si está en nuestro rango
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey]!.add(expense);
      }
    }

    // Convertir a MonthlyExpenseData
    return monthlyData.entries.map((entry) {
      final total = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      return MonthlyExpenseData(
        month: entry.key,
        amount: total,
        expenseCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  /// Detecta gastos recurrentes (misma categoría y monto similar)
  List<Expense> detectRecurringExpenses(
    List<Expense> expenses, {
    double similarityThreshold = 0.1, // 10% de diferencia
  }) {
    final recurring = <Expense>[];

    for (int i = 0; i < expenses.length; i++) {
      final current = expenses[i];
      var matchCount = 0;

      for (int j = 0; j < expenses.length; j++) {
        if (i == j) continue;

        final other = expenses[j];

        // Misma categoría
        if (current.category != other.category) continue;

        // Monto similar
        final difference = (current.amount - other.amount).abs();
        final threshold = current.amount * similarityThreshold;

        if (difference <= threshold) {
          matchCount++;
        }
      }

      // Si hay al menos 2 gastos similares, considerarlo recurrente
      if (matchCount >= 2 && !recurring.contains(current)) {
        recurring.add(current);
      }
    }

    return recurring;
  }

  /// Calcula proyección de gastos para el próximo mes
  double projectNextMonthExpenses(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    // Usar promedio de últimos 3 meses
    final monthlyTrend = calculateMonthlyTrend(expenses, months: 3);

    if (monthlyTrend.isEmpty) return 0;

    final average = monthlyTrend.fold<double>(
      0,
      (sum, data) => sum + data.amount,
    ) / monthlyTrend.length;

    return average;
  }
}
