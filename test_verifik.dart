import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['VERIFIK_API_KEY'] ?? '';

  print('========================================');
  print('PRUEBA DE CONFIGURACIÓN VERIFIK API');
  print('========================================\n');

  print('1. API Key disponible: ${apiKey.isNotEmpty ? "✓ SÍ" : "✗ NO"}');
  if (apiKey.isNotEmpty) {
    print('   Primeros 30 caracteres: ${apiKey.substring(0, apiKey.length > 30 ? 30 : apiKey.length)}...');
    print('   Longitud total: ${apiKey.length} caracteres\n');
  } else {
    print('   ✗ ERROR: No se encontró VERIFIK_API_KEY en el archivo .env\n');
    return;
  }

  print('2. Probando conexión a la API...');

  final url = Uri.parse('https://api.verifik.co/v2/co/runt');

  // Datos de prueba - CAMBIA ESTOS VALORES CON DATOS REALES
  final requestBody = {
    'plate': 'ABC123',  // Cambia por una placa real
    'documentType': 'CC',
    'documentNumber': '1234567890',  // Cambia por un documento real
  };

  print('   URL: $url');
  print('   Body: ${jsonEncode(requestBody)}\n');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('3. Respuesta de la API:');
    print('   Status Code: ${response.statusCode}');
    print('   Status: ${_getStatusText(response.statusCode)}');
    print('   Headers: ${response.headers}');
    print('   Body:\n${_formatJson(response.body)}\n');

    if (response.statusCode == 200) {
      print('✓ ¡ÉXITO! La API respondió correctamente');
    } else if (response.statusCode == 401) {
      print('✗ ERROR: API Key inválida o expirada');
      print('  Verifica que tu API Key sea correcta en el archivo .env');
    } else if (response.statusCode == 404) {
      print('⚠ ADVERTENCIA: No se encontró información para esta placa/documento');
      print('  Esto puede significar que los datos de prueba no existen en RUNT');
      print('  Prueba con una placa y documento reales');
    } else {
      print('✗ ERROR: Respuesta inesperada de la API');
    }

  } catch (e) {
    print('✗ ERROR DE CONEXIÓN: $e');
    print('  Verifica tu conexión a internet');
  }

  print('\n========================================');
  print('FIN DE LA PRUEBA');
  print('========================================');
}

String _getStatusText(int statusCode) {
  switch (statusCode) {
    case 200:
      return 'OK - Solicitud exitosa';
    case 400:
      return 'Bad Request - Solicitud mal formada';
    case 401:
      return 'Unauthorized - API Key inválida';
    case 404:
      return 'Not Found - Recurso no encontrado';
    case 500:
      return 'Internal Server Error - Error del servidor';
    default:
      return 'Código de estado HTTP $statusCode';
  }
}

String _formatJson(String jsonString) {
  try {
    final jsonObj = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObj);
  } catch (e) {
    return jsonString;
  }
}
