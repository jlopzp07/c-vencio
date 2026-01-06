import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/analytics/data/expense_analytics_repository.dart';
import 'package:vehicle_tracker/features/analytics/domain/expense_analytics.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_provider.dart';

/// Provider para el repositorio de analytics
final analyticsRepositoryProvider = Provider<ExpenseAnalyticsRepository>((ref) {
  return ExpenseAnalyticsRepository();
});

/// Provider para analytics de un vehículo específico
final vehicleAnalyticsProvider = FutureProvider.family<ExpenseAnalytics, String>(
  (ref, vehicleId) async {
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);
    final expenses = await ref.watch(expensesProvider(vehicleId).future);

    // Calcular analytics para el último mes
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);

    return analyticsRepo.calculateAnalytics(
      expenses,
      startDate: lastMonth,
      endDate: now,
    );
  },
);

/// Provider para tendencia mensual de un vehículo
final monthlyTrendProvider = FutureProvider.family<List<MonthlyExpenseData>, String>(
  (ref, vehicleId) async {
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);
    final expenses = await ref.watch(expensesProvider(vehicleId).future);

    return analyticsRepo.calculateMonthlyTrend(expenses, months: 6);
  },
);

/// Provider para analytics de período personalizado
final customPeriodAnalyticsProvider = FutureProvider.family<ExpenseAnalytics, CustomPeriodParams>(
  (ref, params) async {
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);
    final expenses = await ref.watch(expensesProvider(params.vehicleId).future);

    return analyticsRepo.calculateAnalytics(
      expenses,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

/// Parámetros para analytics de período personalizado
class CustomPeriodParams {
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const CustomPeriodParams({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPeriodParams &&
          runtimeType == other.runtimeType &&
          vehicleId == other.vehicleId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(vehicleId, startDate, endDate);
}
