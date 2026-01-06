import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/voice_input/data/speech_service.dart';

/// Provider del servicio de speech-to-text
/// Singleton para reutilizar la misma instancia
final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider del estado actual de speech
final speechStateProvider = StreamProvider<SpeechState>((ref) {
  final service = ref.watch(speechServiceProvider);
  return service.stateStream;
});

/// Provider de la transcripción actual
final speechTranscriptionProvider = StreamProvider<String>((ref) {
  final service = ref.watch(speechServiceProvider);
  return service.transcriptionStream;
});
