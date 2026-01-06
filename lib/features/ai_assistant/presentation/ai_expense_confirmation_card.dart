import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_vencio/core/theme/app_theme.dart';
import 'package:c_vencio/core/theme/design_tokens.dart';
import 'package:c_vencio/features/shared/widgets/glass_card.dart';
import 'package:c_vencio/features/ai_assistant/domain/ai_parsed_expense.dart';
import 'package:intl/intl.dart';

/// Card de confirmación para gastos parseados por AI
/// Permite editar los valores antes de guardar
class AiExpenseConfirmationCard extends StatefulWidget {
  final AiParsedExpense parsedExpense;
  final Function(AiParsedExpense) onConfirm;
  final VoidCallback onCancel;

  const AiExpenseConfirmationCard({
    super.key,
    required this.parsedExpense,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<AiExpenseConfirmationCard> createState() =>
      _AiExpenseConfirmationCardState();
}

class _AiExpenseConfirmationCardState extends State<AiExpenseConfirmationCard> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String? _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.parsedExpense.amount?.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.parsedExpense.description ?? '',
    );
    _selectedCategory = widget.parsedExpense.category;
    _selectedDate = widget.parsedExpense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confidence = widget.parsedExpense.confidence;

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con confianza de AI
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gasto detectado por AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildConfidenceBadge(confidence, isDark),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.spaceL),

          // Transcripción original
          _buildOriginalTranscription(isDark),

          const SizedBox(height: DesignTokens.spaceL),

          // Formulario editable
          _buildEditableFields(isDark),

          const SizedBox(height: DesignTokens.spaceL),

          // Botones de acción
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence, bool isDark) {
    Color badgeColor;
    String label;

    if (confidence >= 0.8) {
      badgeColor = AppTheme.accentGreen;
      label = 'Alta confianza';
    } else if (confidence >= 0.5) {
      badgeColor = Colors.orange;
      label = 'Confianza media';
    } else {
      badgeColor = AppTheme.accentRed;
      label = 'Baja confianza';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label (${(confidence * 100).toInt()}%)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildOriginalTranscription(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black38,
          ),
          const SizedBox(width: DesignTokens.spaceS),
          Expanded(
            child: Text(
              widget.parsedExpense.originalText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de monto
        Text(
          'Monto',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: 'Ej: 80000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
          ),
        ),

        const SizedBox(height: DesignTokens.spaceM),

        // Selector de categoría
        Text(
          'Categoría',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
          ),
          items: AiParsedExpense.validCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_translateCategory(category)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: DesignTokens.spaceM),

        // Campo de descripción
        Text(
          'Descripción',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Descripción del gasto...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
          ),
        ),

        const SizedBox(height: DesignTokens.spaceM),

        // Selector de fecha
        Text(
          'Fecha',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black26,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: DesignTokens.spaceS),
                Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceM),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _handleConfirm,
            icon: const Icon(Icons.check),
            label: const Text('Guardar gasto'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleConfirm() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final updatedExpense = widget.parsedExpense.copyWith(
      amount: amount,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    widget.onConfirm(updatedExpense);
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
    };
    return translations[category] ?? category;
  }
}
