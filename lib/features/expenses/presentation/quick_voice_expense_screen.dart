import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/expenses/domain/expense.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_provider.dart';
import 'package:vehicle_tracker/features/ai_assistant/domain/ai_parsed_expense.dart';
import 'package:vehicle_tracker/features/ai_assistant/presentation/gemini_provider.dart';
import 'package:vehicle_tracker/features/ai_assistant/presentation/ai_expense_confirmation_card.dart';
import 'package:vehicle_tracker/features/voice_input/data/speech_service.dart';
import 'package:vehicle_tracker/features/voice_input/presentation/speech_provider.dart';
import 'package:vehicle_tracker/features/voice_input/presentation/widgets/voice_button.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/vehicles_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Pantalla de experiencia rápida para agregar gasto por voz
class QuickVoiceExpenseScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const QuickVoiceExpenseScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<QuickVoiceExpenseScreen> createState() =>
      _QuickVoiceExpenseScreenState();
}

class _QuickVoiceExpenseScreenState
    extends ConsumerState<QuickVoiceExpenseScreen> {
  AiParsedExpense? _parsedExpense;
  bool _isProcessing = false;
  bool _autoStarted = false;
  String _lastProcessedTranscription = '';

  @override
  void initState() {
    super.initState();
    // Activar micrófono automáticamente después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningAutomatically();
    });
  }

  Future<void> _startListeningAutomatically() async {
    if (_autoStarted) return;

    final speechService = ref.read(speechServiceProvider);
    final success = await speechService.startListening();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            speechService.errorMessage ??
                'No se pudo iniciar el reconocimiento de voz',
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }

    setState(() {
      _autoStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final speechService = ref.watch(speechServiceProvider);
    final stateAsync = ref.watch(speechStateProvider);
    final transcriptionAsync = ref.watch(speechTranscriptionProvider);

    // Detectar cuando el speech cambia de listening a idle y procesar automáticamente
    ref.listen<AsyncValue<SpeechState>>(speechStateProvider, (previous, next) {
      next.whenData((currentState) {
        final prevState = previous?.value;

        // Si cambió de listening a idle, procesar la transcripción
        if (prevState == SpeechState.listening &&
            currentState == SpeechState.idle &&
            !_isProcessing &&
            _parsedExpense == null) {
          final transcription = speechService.currentTranscription;
          if (transcription.isNotEmpty &&
              transcription != _lastProcessedTranscription) {
            _lastProcessedTranscription = transcription;
            print('🎯 Auto-procesando transcripción: $transcription');
            _handleTranscription(transcription);
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Agregar con Voz'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            speechService.cancel();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          child: Column(
            children: [
              // Ícono animado según estado
              stateAsync.when(
                data: (state) => _buildMicrophoneIcon(state, isDark),
                loading: () => _buildMicrophoneIcon(SpeechState.idle, isDark),
                error: (_, __) =>
                    _buildMicrophoneIcon(SpeechState.error, isDark),
              ),

              const SizedBox(height: DesignTokens.spaceXL),

              // Área de transcripción en tiempo real
              _buildTranscriptionArea(transcriptionAsync, stateAsync, isDark),

              const SizedBox(height: DesignTokens.spaceL),

              // Texto de ayuda
              stateAsync.when(
                data: (state) => _buildHelpText(state, isDark),
                loading: () => _buildHelpText(SpeechState.idle, isDark),
                error: (_, __) => _buildHelpText(SpeechState.error, isDark),
              ),

              const SizedBox(height: DesignTokens.spaceL),

              // Botón de control de voz
              stateAsync.when(
                data: (state) => VoiceButton(
                  state: state,
                  onTap: () => _handleVoiceButtonTap(speechService, state),
                ),
                loading: () =>
                    VoiceButton(state: SpeechState.idle, onTap: () {}),
                error: (_, __) =>
                    VoiceButton(state: SpeechState.error, onTap: () {}),
              ),

              const SizedBox(height: DesignTokens.spaceXL),

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
        ),
      ),
    );
  }

  Widget _buildMicrophoneIcon(SpeechState state, bool isDark) {
    final isListening = state == SpeechState.listening;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isListening
              ? [
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.primary.withValues(alpha: 0.2),
                ]
              : [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.primary.withValues(alpha: 0.1),
                ],
        ),
        boxShadow: isListening
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
      child: isListening
          ? Shimmer.fromColors(
              baseColor: AppTheme.primary.withValues(alpha: 0.5),
              highlightColor: AppTheme.primary,
              child: const Icon(
                Icons.mic_rounded,
                size: 64,
                color: AppTheme.primary,
              ),
            )
          : const Icon(Icons.mic_rounded, size: 64, color: AppTheme.primary),
    );
  }

  Widget _buildTranscriptionArea(
    AsyncValue<String> transcriptionAsync,
    AsyncValue<SpeechState> stateAsync,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
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
          width: 2,
        ),
      ),
      child: transcriptionAsync.when(
        data: (transcription) {
          if (transcription.isEmpty) {
            return stateAsync.maybeWhen(
              data: (state) => state == SpeechState.listening
                  ? _buildListeningIndicator()
                  : _buildEmptyTranscription(isDark),
              orElse: () => _buildEmptyTranscription(isDark),
            );
          }

          return Text(
            transcription,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          );
        },
        loading: () => _buildEmptyTranscription(isDark),
        error: (err, _) => Text(
          'Error: $err',
          style: const TextStyle(color: AppTheme.accentRed),
        ),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: AppTheme.primary.withValues(alpha: 0.3),
        highlightColor: AppTheme.primary.withValues(alpha: 0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, color: AppTheme.primary, size: 28),
            const SizedBox(width: DesignTokens.spaceM),
            Text(
              'Escuchando...',
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

  Widget _buildEmptyTranscription(bool isDark) {
    return Center(
      child: Text(
        'Habla ahora...',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildHelpText(SpeechState state, bool isDark) {
    String text;
    switch (state) {
      case SpeechState.idle:
        text = 'Toca el botón para comenzar a grabar';
        break;
      case SpeechState.listening:
        text = '🎤 Ejemplo: "Llené el tanque por 80000 pesos"';
        break;
      case SpeechState.error:
        text = 'Error al escuchar. Intenta de nuevo.';
        break;
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: state == SpeechState.error
            ? AppTheme.accentRed
            : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54),
        fontWeight: state == SpeechState.listening
            ? FontWeight.w600
            : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleVoiceButtonTap(
    SpeechService service,
    SpeechState currentState,
  ) async {
    if (currentState == SpeechState.listening) {
      // Detener escucha
      await service.stopListening();

      // Después de un pequeño delay, llamar al callback con la transcripción
      Future.delayed(const Duration(milliseconds: 500), () {
        if (service.currentTranscription.isNotEmpty) {
          _handleTranscription(service.currentTranscription);
        }
      });
    } else {
      // Iniciar escucha
      final success = await service.startListening();

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              service.errorMessage ??
                  'No se pudo iniciar el reconocimiento de voz',
            ),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleTranscription(String transcription) async {
    if (transcription.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectó ningún texto. Intenta de nuevo.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🎤 Transcripción recibida: $transcription');

      final geminiService = ref.read(geminiServiceProvider);
      final vehiclesAsync = await ref.read(vehiclesProvider.future);

      print('🚗 Vehículos disponibles: ${vehiclesAsync.length}');
      print('🤖 Enviando a Gemini...');

      final parsed = await geminiService.parseExpenseFromVoice(
        transcription,
        vehiclesAsync,
      );

      print('✅ Respuesta de Gemini: ${parsed.toJson()}');

      if (!mounted) return;

      setState(() {
        _parsedExpense = parsed;
        _isProcessing = false;
      });

      // Si la confianza es muy baja, mostrar advertencia
      if (parsed.confidence < 0.5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos entender completamente. Por favor revisa los datos.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gasto detectado: ${parsed.category ?? "Sin categoría"} - \$${parsed.amount?.toStringAsFixed(0) ?? "0"}',
            ),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error al procesar: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar: ${e.toString()}'),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
        aiModelVersion: 'gemini-2.0-flash-exp',
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
