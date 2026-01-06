import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Leer API key del archivo .env manualmente
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ ERROR: No se encuentra el archivo .env');
    return;
  }

  String? apiKey;
  final lines = await envFile.readAsLines();
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  print('🔑 API Key configurada: ${apiKey != null && apiKey.isNotEmpty ? "Sí (${apiKey.substring(0, 10)}...)" : "No"}');

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ ERROR: No hay API key de Gemini en .env');
    return;
  }

  try {
    print('🤖 Creando modelo Gemini (gemini-1.5-flash)...');
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    print('📝 Enviando prompt de prueba...');
    final prompt = '''
Parsea este gasto: "Llené el tanque por 80000 pesos"

Responde SOLO con JSON (sin markdown):
{
  "amount": 80000,
  "category": "Fuel",
  "description": "Llenado de tanque",
  "confidence": 0.95
}
''';

    print('⏳ Esperando respuesta...');
    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;

    print('\n✅ Respuesta recibida de Gemini:');
    print('━' * 60);
    print(text);
    print('━' * 60);
    print('\n✅ Gemini está funcionando correctamente!');

  } catch (e, stackTrace) {
    print('\n❌ ERROR al llamar a Gemini:');
    print('Error: $e');
    print('\nStack trace:');
    print(stackTrace);
  }
}
