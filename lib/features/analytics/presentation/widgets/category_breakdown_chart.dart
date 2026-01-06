import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/analytics/domain/expense_analytics.dart';
import 'package:vehicle_tracker/features/shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

/// Gráfica de pastel (pie chart) para desglose de gastos por categoría
class CategoryBreakdownChart extends StatefulWidget {
  final List<CategoryExpense> categories;
  final bool isDark;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
    required this.isDark,
  });

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return _buildEmptyState();
    }

    return GlassCard(
      isDark: widget.isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por Categoría',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceL),
          SizedBox(
            height: 280,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildSections(),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceM),
                // Legend
                Expanded(flex: 2, child: _buildLegend()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = _getCategoryColors();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return List.generate(widget.categories.length, (index) {
      final isTouched = index == _touchedIndex;
      final category = widget.categories[index];
      final radius = isTouched ? 70.0 : 60.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.total,
        title: isTouched
            ? '${category.percentage.toStringAsFixed(1)}%\n${formatter.format(category.total)}'
            : '${category.percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
      );
    });
  }

  Widget _buildLegend() {
    final colors = _getCategoryColors();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return ListView.builder(
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXS),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateCategory(category.category),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formatter.format(category.total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      isDark: widget.isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 64,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black26,
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              'No hay gastos para mostrar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCategoryColors() {
    return [
      AppTheme.primary,
      AppTheme.accentPurple,
      AppTheme.accentGreen,
      const Color(0xFFFFA500), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFFEB3B), // Yellow
    ];
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
      'Accessories': 'Accesorios',
      'Other': 'Otros',
      'Taxes': 'Impuestos',
      'Washing': 'Lavado',
    };
    return translations[category] ?? category;
  }
}
