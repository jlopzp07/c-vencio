import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Cargar .env
  await dotenv.load(fileName: '.env');

  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  print('🔑 API Key configurada: ${apiKey.isNotEmpty ? "Sí (${apiKey.substring(0, 10)}...)" : "No"}');

  if (apiKey.isEmpty) {
    print('❌ ERROR: No hay API key de Gemini');
    return;
  }

  try {
    print('🤖 Creando modelo Gemini...');
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    print('📝 Enviando prompt de prueba...');
    final prompt = '''
Parsea este gasto: "Llené el tanque por 80000 pesos"

Responde SOLO con JSON:
{
  "amount": número,
  "category": "Fuel",
  "description": "texto",
  "confidence": 0.0-1.0
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;

    print('\n✅ Respuesta recibida:');
    print(text);
    print('\n✅ Gemini está funcionando correctamente!');

  } catch (e, stackTrace) {
    print('\n❌ ERROR al llamar a Gemini:');
    print('Error: $e');
    print('\nStack trace:');
    print(stackTrace);
  }
}
