import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:c_vencio/features/ai_assistant/data/gemini_service.dart';

/// Provider del servicio Gemini AI
/// Singleton para reutilizar la misma instancia
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
