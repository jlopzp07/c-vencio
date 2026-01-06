import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/shared/widgets/glass_card.dart';
import 'package:vehicle_tracker/features/voice_input/data/speech_service.dart';
import 'package:vehicle_tracker/features/voice_input/presentation/speech_provider.dart';
import 'package:vehicle_tracker/features/voice_input/presentation/widgets/voice_button.dart';
import 'package:shimmer/shimmer.dart';

/// Widget completo para captura de gastos por voz
/// Incluye botón, visualización de transcripción en tiempo real y estados
class VoiceExpenseWidget extends ConsumerStatefulWidget {
  final Function(String transcription) onTranscriptionComplete;

  const VoiceExpenseWidget({super.key, required this.onTranscriptionComplete});

  @override
  ConsumerState<VoiceExpenseWidget> createState() => _VoiceExpenseWidgetState();
}

class _VoiceExpenseWidgetState extends ConsumerState<VoiceExpenseWidget> {
  SpeechState? _previousState;

  @override
  Widget build(BuildContext context) {
    final speechService = ref.watch(speechServiceProvider);
    final stateAsync = ref.watch(speechStateProvider);
    final transcriptionAsync = ref.watch(speechTranscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Detectar cuando el estado cambia de listening a idle automáticamente
    stateAsync.whenData((currentState) {
      if (_previousState == SpeechState.listening &&
          currentState == SpeechState.idle &&
          speechService.currentTranscription.isNotEmpty) {
        // El reconocimiento terminó automáticamente, procesar la transcripción
        print('🎤 Reconocimiento finalizado automáticamente');
        print('📝 Transcripción: "${speechService.currentTranscription}"');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onTranscriptionComplete(speechService.currentTranscription);
        });
      }
      _previousState = currentState;
    });

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            'Registrar gasto por voz',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceL),

          // Botón de voz
          stateAsync.when(
            data: (state) => VoiceButton(
              state: state,
              onTap: () => _handleVoiceButtonTap(speechService, state),
            ),
            loading: () => VoiceButton(state: SpeechState.idle, onTap: () {}),
            error: (_, __) =>
                VoiceButton(state: SpeechState.error, onTap: () {}),
          ),

          const SizedBox(height: DesignTokens.spaceL),

          // Transcripción
          _buildTranscriptionArea(transcriptionAsync, stateAsync, isDark),

          const SizedBox(height: DesignTokens.spaceM),

          // Mensaje de ayuda
          stateAsync.when(
            data: (state) => _buildHelpText(state, isDark),
            loading: () => _buildHelpText(SpeechState.idle, isDark),
            error: (_, __) => _buildHelpText(SpeechState.error, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionArea(
    AsyncValue<String> transcriptionAsync,
    AsyncValue<SpeechState> stateAsync,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(DesignTokens.spaceM),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          );
        },
        loading: () => _buildEmptyTranscription(isDark),
        error: (err, _) =>
            Text('Error: $err', style: TextStyle(color: AppTheme.accentRed)),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Shimmer.fromColors(
      baseColor: AppTheme.primary.withValues(alpha: 0.3),
      highlightColor: AppTheme.primary.withValues(alpha: 0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic, color: AppTheme.primary),
          const SizedBox(width: DesignTokens.spaceS),
          Text(
            'Escuchando...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTranscription(bool isDark) {
    return Center(
      child: Text(
        'Presiona el botón y di tu gasto',
        style: TextStyle(
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
        text = 'Ejemplo: "Llené el tanque por 80000 pesos"';
        break;
      case SpeechState.listening:
        text = 'Habla ahora... (presiona de nuevo para detener)';
        break;
      case SpeechState.error:
        text = 'Error al escuchar. Intenta de nuevo.';
        break;
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: state == SpeechState.error
            ? AppTheme.accentRed
            : (isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54),
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

      // Llamar al callback con la transcripción si hay contenido
      final transcription = service.currentTranscription;
      print('🎤 Transcripción capturada: "$transcription"');

      if (transcription.isNotEmpty) {
        print('✅ Llamando a onTranscriptionComplete con: "$transcription"');
        widget.onTranscriptionComplete(transcription);
      } else {
        print('❌ Transcripción vacía, no se llama al callback');
      }
    } else {
      // Iniciar escucha
      print('🎤 Iniciando escucha...');
      final success = await service.startListening();

      if (!success && mounted) {
        print('❌ Error al iniciar escucha: ${service.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              service.errorMessage ??
                  'No se pudo iniciar el reconocimiento de voz',
            ),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      } else {
        print('✅ Escucha iniciada correctamente');
      }
    }
  }
}
