import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:c_vencio/core/theme/app_theme.dart';
import 'package:c_vencio/core/theme/design_tokens.dart';
import 'package:c_vencio/features/voice_input/data/speech_service.dart';

/// Botón animado para activar/desactivar entrada de voz
/// Incluye efecto de glow y animaciones
class VoiceButton extends StatelessWidget {
  final SpeechState state;
  final VoidCallback onTap;
  final double size;

  const VoiceButton({
    super.key,
    required this.state,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = state == SpeechState.listening;
    final hasError = state == SpeechState.error;

    return AvatarGlow(
      animate: isListening,
      glowColor: AppTheme.primary,
      glowRadiusFactor: 0.3,
      child: GestureDetector(
        onTap: hasError ? null : onTap,
        child: AnimatedContainer(
          duration: DesignTokens.durationNormal,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getBackgroundColor(isListening, hasError),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(
                  alpha: isListening ? 0.6 : 0.3,
                ),
                blurRadius: isListening ? 20 : 10,
                spreadRadius: isListening ? 2 : 0,
              ),
            ],
          ),
          child: _buildIcon(isListening, hasError),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isListening, bool hasError) {
    if (hasError) return AppTheme.accentRed;
    if (isListening) return AppTheme.primary;
    return AppTheme.primary.withValues(alpha: 0.8);
  }

  Widget _buildIcon(bool isListening, bool hasError) {
    IconData iconData;
    if (hasError) {
      iconData = Icons.error_outline;
    } else if (isListening) {
      iconData = Icons.stop;
    } else {
      iconData = Icons.mic;
    }

    return Icon(iconData, color: Colors.white, size: size * 0.5);
  }
}
