import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/analytics/presentation/analytics_provider.dart';
import 'package:vehicle_tracker/features/analytics/presentation/widgets/category_breakdown_chart.dart';
import 'package:vehicle_tracker/features/analytics/presentation/widgets/monthly_trend_chart.dart';
import 'package:vehicle_tracker/features/expenses/domain/expense.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_provider.dart';
import 'package:vehicle_tracker/features/shared/widgets/glass_card.dart';

/// Screen rediseñado para gastos con MonAI style, charts y filtros
class ExpensesScreenV2 extends ConsumerStatefulWidget {
  final String vehicleId;

  const ExpensesScreenV2({super.key, required this.vehicleId});

  @override
  ConsumerState<ExpensesScreenV2> createState() => _ExpensesScreenV2State();
}

class _ExpensesScreenV2State extends ConsumerState<ExpensesScreenV2> {
  String? _selectedCategory;
  bool _showCharts = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expensesAsync = ref.watch(expensesProvider(widget.vehicleId));
    final analyticsAsync = ref.watch(
      vehicleAnalyticsProvider(widget.vehicleId),
    );
    final monthlyTrendAsync = ref.watch(monthlyTrendProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
            icon: Icon(
              _showCharts ? Icons.list_rounded : Icons.bar_chart_rounded,
            ),
            onPressed: () {
              setState(() {
                _showCharts = !_showCharts;
              });
            },
            tooltip: _showCharts ? 'Ver lista' : 'Ver gráficas',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(
              '/vehicle-details/add-expense',
              extra: widget.vehicleId,
            ),
            tooltip: 'Agregar gasto',
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return _buildEmptyState(isDark);
          }

          // Filtrar por categoría si se seleccionó una
          final filteredExpenses = _selectedCategory != null
              ? expenses.where((e) => e.category == _selectedCategory).toList()
              : expenses;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(expensesProvider(widget.vehicleId));
              ref.invalidate(vehicleAnalyticsProvider(widget.vehicleId));
              ref.invalidate(monthlyTrendProvider(widget.vehicleId));
            },
            child: CustomScrollView(
              slivers: [
                // Header con total y filtros
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceL),
                    child: _buildHeader(expenses, isDark),
                  ),
                ),

                // Filtros de categoría
                SliverToBoxAdapter(
                  child: _buildCategoryFilters(expenses, isDark),
                ),

                // Gráficas o lista según el toggle
                if (_showCharts) ...[
                  // Charts
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spaceL),
                      child: Column(
                        children: [
                          // Category breakdown
                          analyticsAsync.when(
                            data: (analytics) => CategoryBreakdownChart(
                              categories: analytics.byCategory,
                              isDark: isDark,
                            ),
                            loading: () => const SizedBox(
                              height: 300,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: DesignTokens.spaceL),
                          // Monthly trend
                          monthlyTrendAsync.when(
                            data: (monthlyData) => MonthlyTrendChart(
                              monthlyData: monthlyData,
                              isDark: isDark,
                            ),
                            loading: () => const SizedBox(
                              height: 300,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Lista de gastos
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceL,
                      vertical: DesignTokens.spaceM,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final expense = filteredExpenses[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: DesignTokens.spaceM,
                          ),
                          child: _buildExpenseCard(expense, isDark),
                        );
                      }, childCount: filteredExpenses.length),
                    ),
                  ),
                ],

                // Espaciado al final
                const SliverToBoxAdapter(
                  child: SizedBox(height: DesignTokens.spaceXL),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.accentRed,
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Text(
                'Error al cargar gastos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: DesignTokens.spaceS),
              Text(
                err.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Expense> expenses, bool isDark) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de Gastos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black54,
                  ),
                ),
                Text(
                  formatter.format(total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '${expenses.length} ${expenses.length == 1 ? 'gasto' : 'gastos'} registrados',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(List<Expense> expenses, bool isDark) {
    // Obtener categorías únicas
    final categories = expenses.map((e) => e.category).toSet().toList()..sort();

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceL,
          vertical: DesignTokens.spaceS,
        ),
        children: [
          // Botón "Todas"
          Padding(
            padding: const EdgeInsets.only(right: DesignTokens.spaceS),
            child: _buildFilterChip(
              label: 'Todas',
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
              isDark: isDark,
            ),
          ),
          // Botones de categorías
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: DesignTokens.spaceS),
              child: _buildFilterChip(
                label: _translateCategory(category),
                isSelected: _selectedCategory == category,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceM,
          vertical: DesignTokens.spaceS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.2)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense, bool isDark) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DesignTokens.spaceL),
        decoration: BoxDecoration(
          color: AppTheme.accentRed,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar gasto'),
                content: const Text('¿Estás seguro de eliminar este gasto?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        await ref.deleteExpense(expense.id, widget.vehicleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gasto eliminado'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }
      },
      child: GlassCard(
        isDark: isDark,
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceM),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  expense.category,
                ).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForCategory(expense.category),
                color: _getCategoryColor(expense.category),
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translateCategory(expense.category),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (expense.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(expense.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatter.format(expense.amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 120,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black12,
            ),
            const SizedBox(height: DesignTokens.spaceL),
            Text(
              'No hay gastos registrados',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              'Presiona el botón + para agregar tu primer gasto',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceXL),
            FilledButton.icon(
              onPressed: () => context.push(
                '/vehicle-details/add-expense',
                extra: widget.vehicleId,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar Gasto'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceXL,
                  vertical: DesignTokens.spaceM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    const icons = {
      'Fuel': Icons.local_gas_station_rounded,
      'Maintenance': Icons.build_circle_rounded,
      'Insurance': Icons.shield_rounded,
      'Parking': Icons.local_parking_rounded,
      'Tolls': Icons.toll_rounded,
      'Repairs': Icons.construction_rounded,
      'Cleaning': Icons.local_car_wash_rounded,
      'Washing': Icons.local_car_wash_rounded,
      'Accessories': Icons.shopping_bag_rounded,
      'Taxes': Icons.receipt_long_rounded,
      'Other': Icons.category_rounded,
    };
    return icons[category] ?? Icons.receipt_rounded;
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'Fuel': AppTheme.primary,
      'Maintenance': AppTheme.accentOrange,
      'Insurance': AppTheme.accentCyan,
      'Parking': AppTheme.accentPurple,
      'Tolls': AppTheme.accentYellow,
      'Repairs': AppTheme.accentRed,
      'Cleaning': AppTheme.accentCyan,
      'Washing': AppTheme.accentCyan,
      'Accessories': AppTheme.accentGreen,
      'Taxes': AppTheme.accentOrange,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  String _translateCategory(String category) {
    const translations = {
      'Fuel': 'Combustible',
      'Maintenance': 'Mantenimiento',
      'Insurance': 'Seguro',
      'Parking': 'Estacionamiento',
      'Tolls': 'Peajes',
      'Repairs': 'Reparaciones',
      'Cleaning': 'Lavado',
      'Washing': 'Lavado',
      'Accessories': 'Accesorios',
      'Taxes': 'Impuestos',
      'Other': 'Otros',
    };
    return translations[category] ?? category;
  }
}
