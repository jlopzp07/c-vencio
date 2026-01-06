import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:c_vencio/features/expenses/domain/expense.dart';
import 'package:c_vencio/features/expenses/presentation/expenses_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const AddExpenseScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Fuel';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Fuel',
    'Maintenance',
    'Taxes',
    'Parking',
    'Washing',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final expense = Expense(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId,
        category: _category,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      await ref.addExpense(expense, widget.vehicleId);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryIcons = {
      'Fuel': Icons.local_gas_station_rounded,
      'Maintenance': Icons.build_circle_rounded,
      'Taxes': Icons.receipt_long_rounded,
      'Parking': Icons.local_parking_rounded,
      'Washing': Icons.local_car_wash_rounded,
      'Other': Icons.category_rounded,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFFEB1555).withValues(alpha: 0.15)
                        : const Color(0xFFEB1555).withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.attach_money_rounded,
                    size: 64,
                    color: Color(0xFFEB1555),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  hintText: '50000',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(
                                categoryIcons[c] ?? Icons.category,
                                size: 20,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Text(_translateCategory(c)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Ej: Tanqueada en la estación X',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Preview Card
              if (_amountController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1D1E33).withValues(alpha: 0.5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade300,
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
                          const SizedBox(width: 8),
                          Text(
                            'Vista Previa',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _translateCategory(_category),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$ ${_amountController.text}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEB1555),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy', 'es').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: _isLoading ? null : _saveExpense,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 24),
                          SizedBox(width: 8),
                          Text('Guardar Gasto', style: TextStyle(fontSize: 16)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateCategory(String category) {
    const translations = {
      'Fuel': 'Combustible',
      'Maintenance': 'Mantenimiento',
      'Taxes': 'Impuestos',
      'Parking': 'Parqueadero',
      'Washing': 'Lavado',
      'Other': 'Otro',
    };
    return translations[category] ?? category;
  }
}
