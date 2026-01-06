import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vehicle_tracker/core/constants/app_constants.dart';
import 'package:vehicle_tracker/features/ai_assistant/domain/ai_parsed_expense.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';

/// Servicio para integración con Google Gemini AI
/// Maneja parsing de gastos desde voz y generación de sugerencias
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(
        'Gemini API Key no configurada. '
        'Agrega tu API key en .env: GEMINI_API_KEY=tu_clave'
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',  // Gemini 2.5 Flash
      apiKey: apiKey,
    );
  }

  /// Parsea un gasto desde texto de entrada de voz
  ///
  /// Ejemplos de entrada válidos:
  /// - "Llené el tanque por 80000 pesos"
  /// - "Mantenimiento 250000"
  /// - "Gasolina 50000 del Toyota"
  Future<AiParsedExpense> parseExpenseFromVoice(
    String transcription,
    List<Vehicle> availableVehicles,
  ) async {
    final prompt = _buildExpenseParsingPrompt(transcription, availableVehicles);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        return _createFallbackExpense(transcription, 0.0);
      }

      // Intentar parsear respuesta JSON
      try {
        // Extraer JSON del texto (puede venir con markdown)
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;

        if (jsonStart == -1 || jsonEnd <= jsonStart) {
          return _createFallbackExpense(transcription, 0.3);
        }

        final jsonStr = text.substring(jsonStart, jsonEnd);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

        return AiParsedExpense(
          amount: (parsed['amount'] as num?)?.toDouble(),
          category: parsed['category'] as String?,
          description: parsed['description'] as String?,
          confidence: (parsed['confidence'] as num?)?.toDouble() ?? 0.5,
          originalText: transcription,
          vehicleId: parsed['vehicleId'] as String?,
        );
      } catch (e) {
        // Si falla el parsing JSON, usar fallback con regex
        return _parseWithRegex(transcription);
      }
    } catch (e) {
      // Error de API, usar fallback regex
      return _parseWithRegex(transcription);
    }
  }

  /// Construye el prompt para parsing de gastos
  String _buildExpenseParsingPrompt(
    String transcription,
    List<Vehicle> vehicles,
  ) {
    final vehiclesList = vehicles
        .map((v) => '- ${v.brand} ${v.model} (ID: ${v.id})')
        .join('\n');

    return '''
Eres un asistente para registrar gastos de vehículos en Colombia.

VEHÍCULOS DISPONIBLES:
$vehiclesList

ENTRADA DEL USUARIO: "$transcription"

CATEGORÍAS VÁLIDAS:
- Fuel (combustible, gasolina, llenado, tanque)
- Maintenance (mantenimiento, revisión, servicio)
- Insurance (seguro, SOAT)
- Parking (estacionamiento, parqueadero)
- Tolls (peajes)
- Repairs (reparaciones, arreglos)
- Cleaning (lavado, limpieza)
- Accessories (accesorios)
- Other (otros)

INSTRUCCIONES:
1. Extrae el MONTO del gasto (números, puede estar en pesos colombianos)
2. Detecta la CATEGORÍA basándote en las palabras clave
3. Genera una DESCRIPCIÓN concisa
4. Si menciona un vehículo específico, identifica su ID
5. Asigna un nivel de CONFIANZA (0.0 a 1.0) basado en qué tan clara es la información

RESPONDE SOLO CON UN OBJETO JSON (sin markdown, sin explicaciones):
{
  "amount": número o null,
  "category": "Fuel" | "Maintenance" | etc. o null,
  "description": "descripción breve",
  "confidence": 0.0 a 1.0,
  "vehicleId": "ID del vehículo" o null
}

EJEMPLOS:
Input: "Llené el tanque por 80000 pesos"
Output: {"amount": 80000, "category": "Fuel", "description": "Llenado de tanque", "confidence": 0.95, "vehicleId": null}

Input: "Mantenimiento 250000 del Toyota"
Output: {"amount": 250000, "category": "Maintenance", "description": "Mantenimiento del Toyota", "confidence": 0.9, "vehicleId": "ID_SI_EXISTE"}
''';
  }

  /// Parser de fallback usando regex cuando AI falla
  AiParsedExpense _parseWithRegex(String text) {
    // Buscar números (monto)
    final amountRegex = RegExp(r'\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?');
    final amountMatch = amountRegex.firstMatch(text);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(0)!.replaceAll(RegExp(r'[.,]'), ''))
        : null;

    // Detectar categoría por palabras clave
    String? category;
    final lowerText = text.toLowerCase();

    if (lowerText.contains(RegExp(r'gasolina|combustible|tanque|llen'))) {
      category = 'Fuel';
    } else if (lowerText.contains(RegExp(r'mantenimiento|servicio|revisi'))) {
      category = 'Maintenance';
    } else if (lowerText.contains(RegExp(r'seguro|soat'))) {
      category = 'Insurance';
    } else if (lowerText.contains(RegExp(r'parqu|estacion'))) {
      category = 'Parking';
    } else if (lowerText.contains(RegExp(r'peaje'))) {
      category = 'Tolls';
    } else if (lowerText.contains(RegExp(r'reparac|arreglo'))) {
      category = 'Repairs';
    } else if (lowerText.contains(RegExp(r'lavado|limpieza'))) {
      category = 'Cleaning';
    }

    final confidence = (amount != null && category != null) ? 0.7 : 0.3;

    return AiParsedExpense(
      amount: amount,
      category: category,
      description: text.length > 50 ? '${text.substring(0, 47)}...' : text,
      confidence: confidence,
      originalText: text,
    );
  }

  /// Crea un expense de fallback cuando todo falla
  AiParsedExpense _createFallbackExpense(String text, double confidence) {
    return AiParsedExpense(
      amount: null,
      category: null,
      description: text,
      confidence: confidence,
      originalText: text,
    );
  }
}
