import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:c_vencio/core/theme/app_theme.dart';
import 'package:c_vencio/core/theme/design_tokens.dart';
import 'package:c_vencio/features/expenses/domain/expense.dart';

/// Formulario manual para agregar gastos con glassmorphism
class ManualExpenseForm extends StatefulWidget {
  final Function(Expense) onSave;
  final String vehicleId;

  const ManualExpenseForm({
    super.key,
    required this.onSave,
    required this.vehicleId,
  });

  @override
  State<ManualExpenseForm> createState() => _ManualExpenseFormState();
}

class _ManualExpenseFormState extends State<ManualExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Fuel';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spaceL),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.2),
                      AppTheme.primary.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.attach_money_rounded,
                  size: 48,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXL),

            // Amount field
            _buildGlassField(
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Monto',
                  hintText: '50000',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  prefixText: '\$ ',
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                onChanged: (_) =>
                    setState(() {}), // Trigger rebuild for preview
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Número inválido';
                  if (double.parse(value) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              isDark: isDark,
            ),

            const SizedBox(height: DesignTokens.spaceL),

            // Category dropdown
            _buildGlassField(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(
                    _getCategoryIcon(_selectedCategory),
                    color: _getCategoryColor(_selectedCategory),
                  ),
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                  ),
                ),
                items: _getCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 20,
                          color: _getCategoryColor(category),
                        ),
                        const SizedBox(width: DesignTokens.spaceS),
                        Text(_translateCategory(category)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              isDark: isDark,
            ),

            const SizedBox(height: DesignTokens.spaceL),

            // Date picker
            _buildGlassField(
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black54,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              isDark: isDark,
            ),

            const SizedBox(height: DesignTokens.spaceL),

            // Description field
            _buildGlassField(
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Ej: Tanqueada en la estación X',
                  prefixIcon: const Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                  ),
                ),
              ),
              isDark: isDark,
            ),

            const SizedBox(height: DesignTokens.spaceXL),

            // Preview card
            if (_amountController.text.isNotEmpty) _buildPreviewCard(isDark),

            const SizedBox(height: DesignTokens.spaceXL),

            // Save button
            FilledButton(
              onPressed: _handleSave,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 24),
                  const SizedBox(width: DesignTokens.spaceS),
                  Text(
                    'Guardar Gasto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassField({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceS,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview_outlined,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(width: DesignTokens.spaceS),
                  Text(
                    'Vista Previa',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceS),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        _selectedCategory,
                      ).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(_selectedCategory),
                      color: _getCategoryColor(_selectedCategory),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _translateCategory(_selectedCategory),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black54,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$ ${_amountController.text}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    // No necesitamos UUID aquí, se crea en el padre
    widget.onSave(
      Expense(
        id: '', // Se reemplazará en el padre
        vehicleId: widget.vehicleId,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        parsedByAi: false,
      ),
    );
  }

  List<String> _getCategories() {
    return [
      'Fuel',
      'Maintenance',
      'Insurance',
      'Parking',
      'Tolls',
      'Repairs',
      'Cleaning',
      'Accessories',
      'Taxes',
      'Other',
    ];
  }

  IconData _getCategoryIcon(String category) {
    const icons = {
      'Fuel': Icons.local_gas_station_rounded,
      'Maintenance': Icons.build_circle_rounded,
      'Insurance': Icons.shield_rounded,
      'Parking': Icons.local_parking_rounded,
      'Tolls': Icons.toll_rounded,
      'Repairs': Icons.construction_rounded,
      'Cleaning': Icons.local_car_wash_rounded,
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
      'Accessories': 'Accesorios',
      'Taxes': 'Impuestos',
      'Other': 'Otros',
    };
    return translations[category] ?? category;
  }
}
