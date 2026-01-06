import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

/// Estados del servicio de speech-to-text
enum SpeechState {
  idle,       // Inactivo
  listening,  // Escuchando
  error,      // Error
}

/// Servicio para manejo de entrada de voz usando speech_to_text
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Estado actual del servicio
  final _stateController = StreamController<SpeechState>.broadcast();
  Stream<SpeechState> get stateStream => _stateController.stream;
  SpeechState _currentState = SpeechState.idle;
  SpeechState get currentState => _currentState;

  /// Transcripción actual
  final _transcriptionController = StreamController<String>.broadcast();
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  String _currentTranscription = '';
  String get currentTranscription => _currentTranscription;

  /// Nivel de confianza de la transcripción (0.0 - 1.0)
  double _confidence = 0.0;
  double get confidence => _confidence;

  /// Mensaje de error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Si el servicio está disponible en el dispositivo
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// Si el servicio está inicializado
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio de speech-to-text
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isAvailable = await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: kDebugMode,
      );

      _isInitialized = _isAvailable;
      return _isAvailable;
    } catch (e) {
      _updateError('Error al inicializar reconocimiento de voz: $e');
      return false;
    }
  }

  /// Comienza a escuchar entrada de voz
  Future<bool> startListening({
    String localeId = 'es_CO', // Español de Colombia
    Duration? timeout,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _updateError('Servicio de voz no disponible en este dispositivo');
        return false;
      }
    }

    if (_currentState == SpeechState.listening) {
      return true; // Ya está escuchando
    }

    try {
      _currentTranscription = '';
      _confidence = 0.0;
      _errorMessage = null;
      _updateState(SpeechState.listening);

      await _speech.listen(
        onResult: _handleResult,
        localeId: localeId,
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );

      return true;
    } catch (e) {
      _updateError('Error al iniciar escucha: $e');
      return false;
    }
  }

  /// Detiene la escucha
  Future<void> stopListening() async {
    if (_currentState != SpeechState.listening) return;

    try {
      await _speech.stop();
      // Cambiar directamente a idle después de detener
      _updateState(_currentTranscription.isNotEmpty
          ? SpeechState.idle
          : SpeechState.error);
    } catch (e) {
      _updateError('Error al detener escucha: $e');
    }
  }

  /// Cancela la escucha actual
  Future<void> cancel() async {
    try {
      await _speech.cancel();
      _currentTranscription = '';
      _confidence = 0.0;
      _updateState(SpeechState.idle);
    } catch (e) {
      _updateError('Error al cancelar: $e');
    }
  }

  /// Maneja los resultados de speech-to-text
  void _handleResult(result) {
    _currentTranscription = result.recognizedWords;
    _confidence = result.confidence;
    _transcriptionController.add(_currentTranscription);

    // Si el resultado es final, detener automáticamente
    if (result.finalResult) {
      stopListening();
    }
  }

  /// Maneja cambios de estado del sistema de speech
  void _handleStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_currentState == SpeechState.listening) {
        _updateState(SpeechState.idle);
      }
    }
  }

  /// Maneja errores del sistema de speech
  void _handleError(error) {
    _updateError('Error de reconocimiento: ${error.errorMsg}');
  }

  /// Actualiza el estado actual
  void _updateState(SpeechState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Actualiza el mensaje de error
  void _updateError(String message) {
    _errorMessage = message;
    _updateState(SpeechState.error);
  }

  /// Obtiene los idiomas disponibles
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  /// Limpia recursos
  void dispose() {
    _speech.stop();
    _stateController.close();
    _transcriptionController.close();
  }
}
