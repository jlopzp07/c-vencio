import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/analytics/domain/expense_analytics.dart';
import 'package:vehicle_tracker/features/shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

/// Gráfica de línea para tendencia mensual de gastos
class MonthlyTrendChart extends StatefulWidget {
  final List<MonthlyExpenseData> monthlyData;
  final bool isDark;

  const MonthlyTrendChart({
    super.key,
    required this.monthlyData,
    required this.isDark,
  });

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.monthlyData.isEmpty) {
      return _buildEmptyState();
    }

    return GlassCard(
      isDark: widget.isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia Mensual',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          _buildSummaryRow(),
          const SizedBox(height: DesignTokens.spaceL),
          SizedBox(height: 220, child: LineChart(_buildLineChartData())),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final total = widget.monthlyData.fold<double>(
      0,
      (sum, data) => sum + data.amount,
    );
    final average = widget.monthlyData.isNotEmpty
        ? total / widget.monthlyData.length
        : 0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Promedio',
            formatter.format(average),
            Icons.trending_flat_rounded,
            AppTheme.accentCyan,
          ),
        ),
        const SizedBox(width: DesignTokens.spaceM),
        Expanded(
          child: _buildSummaryCard(
            'Total',
            formatter.format(total),
            Icons.attach_money_rounded,
            AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: DesignTokens.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final maxY = widget.monthlyData.isEmpty
        ? 100.0
        : widget.monthlyData
              .map((e) => e.amount)
              .reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _buildBottomTitle,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxY / 5,
            getTitlesWidget: _buildLeftTitle,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            width: 1,
          ),
          left: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      minX: 0,
      maxX: (widget.monthlyData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY * 1.1,
      lineBarsData: [
        LineChartBarData(
          spots: _buildSpots(),
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: AppTheme.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.3),
                AppTheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              widget.isDark ? const Color(0xFF1D1E33) : Colors.white,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final monthData = widget.monthlyData[spot.x.toInt()];
              final formatter = NumberFormat.currency(
                symbol: '\$',
                decimalDigits: 0,
              );
              return LineTooltipItem(
                '${monthData.monthLabel}\n${formatter.format(spot.y)}\n${monthData.expenseCount} gastos',
                TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return List.generate(
      widget.monthlyData.length,
      (index) => FlSpot(index.toDouble(), widget.monthlyData[index].amount),
    );
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value < 0 || value >= widget.monthlyData.length) {
      return const SizedBox.shrink();
    }

    final monthData = widget.monthlyData[value.toInt()];
    return Text(
      monthData.monthLabel,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.black54,
        fontSize: 11,
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    final formatter = NumberFormat.compact();
    return Text(
      '\$${formatter.format(value)}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.black54,
        fontSize: 10,
      ),
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
              Icons.show_chart_rounded,
              size: 64,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black26,
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              'No hay datos para mostrar',
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
}
