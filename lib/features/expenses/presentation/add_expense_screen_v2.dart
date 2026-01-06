import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:c_vencio/core/constants/app_constants.dart';
import 'package:c_vencio/core/theme/app_theme.dart';
import 'package:c_vencio/core/theme/design_tokens.dart';
import 'package:c_vencio/features/expenses/domain/expense.dart';
import 'package:c_vencio/features/expenses/presentation/expenses_provider.dart';
import 'package:c_vencio/features/expenses/presentation/widgets/manual_expense_form.dart';
import 'package:c_vencio/features/ai_assistant/domain/ai_parsed_expense.dart';
import 'package:c_vencio/features/ai_assistant/presentation/gemini_provider.dart';
import 'package:c_vencio/features/ai_assistant/presentation/ai_expense_confirmation_card.dart';
import 'package:c_vencio/features/voice_input/presentation/widgets/voice_expense_widget.dart';
import 'package:c_vencio/features/vehicles/presentation/vehicles_provider.dart';

/// Screen rediseñado para agregar gastos con soporte de voz + AI
class AddExpenseScreenV2 extends ConsumerStatefulWidget {
  final String vehicleId;

  const AddExpenseScreenV2({super.key, required this.vehicleId});

  @override
  ConsumerState<AddExpenseScreenV2> createState() => _AddExpenseScreenV2State();
}

class _AddExpenseScreenV2State extends ConsumerState<AddExpenseScreenV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AiParsedExpense? _parsedExpense;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppConstants.enableVoiceInput ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
        bottom: AppConstants.enableVoiceInput
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.mic), text: 'Por Voz'),
                  Tab(icon: Icon(Icons.edit), text: 'Manual'),
                ],
              )
            : null,
      ),
      body: AppConstants.enableVoiceInput
          ? TabBarView(
              controller: _tabController,
              children: [_buildVoiceTab(isDark), _buildManualTab(isDark)],
            )
          : _buildManualTab(isDark),
    );
  }

  Widget _buildVoiceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        children: [
          // Widget de voz
          VoiceExpenseWidget(onTranscriptionComplete: _handleTranscription),

          const SizedBox(height: DesignTokens.spaceL),

          // Card de confirmación si ya se parseó
          if (_parsedExpense != null && !_isProcessing)
            AiExpenseConfirmationCard(
              parsedExpense: _parsedExpense!,
              onConfirm: _saveAiExpense,
              onCancel: () {
                setState(() {
                  _parsedExpense = null;
                });
              },
            ),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXL),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: DesignTokens.spaceM),
                  Text(
                    'Procesando con IA...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualTab(bool isDark) {
    return ManualExpenseForm(
      vehicleId: widget.vehicleId,
      onSave: _saveManualExpense,
    );
  }

  Future<void> _saveManualExpense(Expense expenseTemplate) async {
    try {
      // Crear expense con ID único
      final expense = Expense(
        id: const Uuid().v4(),
        vehicleId: expenseTemplate.vehicleId,
        category: expenseTemplate.category,
        amount: expenseTemplate.amount,
        date: expenseTemplate.date,
        description: expenseTemplate.description,
        parsedByAi: false,
      );

      await ref.addExpense(expense, widget.vehicleId);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado exitosamente'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleTranscription(String transcription) async {
    print('📝 _handleTranscription llamado con: "$transcription"');

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🤖 Obteniendo servicio de Gemini...');
      final geminiService = ref.read(geminiServiceProvider);

      print('🚗 Obteniendo vehículos...');
      final vehiclesAsync = await ref.read(vehiclesProvider.future);
      print('🚗 Vehículos obtenidos: ${vehiclesAsync.length}');

      print('🤖 Llamando a parseExpenseFromVoice...');
      final parsed = await geminiService.parseExpenseFromVoice(
        transcription,
        vehiclesAsync,
      );

      print('✅ Respuesta de Gemini:');
      print('  - Monto: ${parsed.amount}');
      print('  - Categoría: ${parsed.category}');
      print('  - Descripción: ${parsed.description}');
      print('  - Confianza: ${parsed.confidence}');
      print('  - Es válido: ${parsed.isValid}');

      // Si el gasto es válido (tiene monto y categoría), guardarlo automáticamente
      if (parsed.isValid && mounted) {
        print('✅ Gasto válido, guardando automáticamente...');
        await _saveAiExpenseAutomatically(parsed);
      } else {
        print('⚠️ Gasto no válido, mostrando card de confirmación');
        // Si no es válido, mostrar el card de confirmación para edición manual
        setState(() {
          _parsedExpense = parsed;
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No pudimos entender completamente. Por favor revisa los datos.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error en _handleTranscription: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _saveAiExpenseAutomatically(
    AiParsedExpense parsedExpense,
  ) async {
    try {
      final expense = Expense(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId,
        category: parsedExpense.category!,
        amount: parsedExpense.amount!,
        date: parsedExpense.date,
        description: parsedExpense.description,
        // AI metadata
        aiConfidence: parsedExpense.confidence,
        originalTranscription: parsedExpense.originalText,
        parsedByAi: true,
        aiModelVersion: 'gemini-2.5-flash',
      );

      await ref.addExpense(expense, widget.vehicleId);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        // Mostrar mensaje de éxito con detalles del gasto
        final categoryName = _translateCategory(expense.category);
        final formattedAmount = NumberFormat.currency(
          symbol: '\$',
          decimalDigits: 0,
        ).format(expense.amount);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Gasto creado exitosamente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Categoría: $categoryName'),
                Text('Monto: $formattedAmount'),
                if (expense.description != null &&
                    expense.description!.isNotEmpty)
                  Text('Descripción: ${expense.description}'),
                Text(
                  'Confianza AI: ${(parsedExpense.confidence * 100).toInt()}%',
                ),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Volver a la pantalla anterior después de un pequeño delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
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

  Future<void> _saveAiExpense(AiParsedExpense parsedExpense) async {
    if (!parsedExpense.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    try {
      final expense = Expense(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId,
        category: parsedExpense.category!,
        amount: parsedExpense.amount!,
        date: parsedExpense.date,
        description: parsedExpense.description,
        // AI metadata
        aiConfidence: parsedExpense.confidence,
        originalTranscription: parsedExpense.originalText,
        parsedByAi: true,
        aiModelVersion: 'gemini-1.5-flash',
      );

      await ref.addExpense(expense, widget.vehicleId);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado exitosamente'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }
}
