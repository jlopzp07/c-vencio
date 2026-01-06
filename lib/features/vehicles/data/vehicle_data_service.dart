import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vehicle_tracker/core/constants/app_constants.dart';
import 'dart:developer' as developer;

final vehicleDataServiceProvider = Provider((ref) => VehicleDataService());

class VehicleDataService {
  // Verifik API Base URL
  static const String _baseUrl = 'https://api.verifik.co/v2';

  /// Consulta información del vehículo usando la API de Verifik
  ///
  /// Requiere:
  /// - [licensePlate]: Placa del vehículo
  /// - [ownerDocType]: Tipo de documento del propietario (CC, CE, PA, RC, NIT)
  /// - [ownerDocNumber]: Número de documento del propietario
  ///
  /// Retorna información del RUNT incluyendo SOAT y Tecnicomecánica
  Future<Map<String, dynamic>> getVehicleData({
    required String licensePlate,
    required String ownerDocType,
    required String ownerDocNumber,
  }) async {
    final apiKey = AppConstants.verifikApiKey;

    // Construir URL con parámetros de query (según documentación oficial)
    final url = Uri.parse('$_baseUrl/co/runt/vehicle-by-plate').replace(
      queryParameters: {
        'plate': licensePlate.toUpperCase(),
        'documentType': ownerDocType.toUpperCase(),
        'documentNumber': ownerDocNumber,
      },
    );

    // Log para debug
    developer.log('=== VERIFIK API REQUEST ===');
    developer.log('API Key disponible: ${apiKey.isNotEmpty}');
    developer.log('API Key (primeros 30 chars): ${apiKey.substring(0, apiKey.length > 30 ? 30 : apiKey.length)}...');
    developer.log('URL completa: $url');
    developer.log('Placa: ${licensePlate.toUpperCase()}');
    developer.log('Documento: $ownerDocType $ownerDocNumber');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      );

      developer.log('=== VERIFIK API RESPONSE ===');
      developer.log('Status Code: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseVerifikResponse(data);
      } else if (response.statusCode == 401) {
        throw Exception('API Key inválida o expirada. Verifica tu configuración en el archivo .env');
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró información para la placa "${licensePlate.toUpperCase()}" con el documento proporcionado');
      } else if (response.statusCode == 409) {
        throw Exception('Conflicto en la solicitud. Verifica que los datos sean correctos');
      } else {
        final errorBody = response.body;
        developer.log('Error Response: $errorBody');
        throw Exception('Error ${response.statusCode}: $errorBody');
      }
    } on http.ClientException catch (e) {
      developer.log('ClientException: $e');
      throw Exception('Error de conexión: Verifica tu conexión a internet');
    } catch (e) {
      developer.log('General Exception: $e');
      rethrow;
    }
  }

  /// Parsea la respuesta de Verifik según el formato oficial de la API
  /// Documentación: https://api.verifik.co/v2/co/runt/vehicle-by-plate
  Map<String, dynamic> _parseVerifikResponse(Map<String, dynamic> response) {
    developer.log('=== PARSING VERIFIK RESPONSE ===');
    developer.log('Full Response: ${jsonEncode(response)}');

    final result = <String, dynamic>{};

    // La respuesta viene en el formato:
    // { "data": { "informacionGeneral": {...}, "soat": [...], "tecnoMecanica": [...] } }
    if (!response.containsKey('data')) {
      developer.log('⚠ No se encontró el campo "data" en la respuesta');
      return result;
    }

    final data = response['data'] as Map<String, dynamic>;

    // Parsear SOAT (viene como array)
    if (data.containsKey('soat') && data['soat'] is List) {
      final soatList = data['soat'] as List;
      if (soatList.isNotEmpty) {
        final soat = soatList[0] as Map<String, dynamic>;
        developer.log('SOAT encontrado: ${jsonEncode(soat)}');

        result['soat'] = {
          'vigente': soat['estado'] == 'VIGENTE',
          'estado': soat['estado'] ?? 'DESCONOCIDO',
          'fechaVencimiento': soat['fechaVencimiento'],
          'fechaVigencia': soat['fechaVigencia'],
          'fechaExpedicion': soat['fechaExpedicion'],
          'aseguradora': soat['entidadExpideSoat'],
          'numeroPoliza': soat['noPoliza'],
        };
      }
    }

    // Parsear Tecnicomecánica (viene como array)
    if (data.containsKey('tecnoMecanica') && data['tecnoMecanica'] is List) {
      final tecnoList = data['tecnoMecanica'] as List;
      if (tecnoList.isNotEmpty) {
        final tecno = tecnoList[0] as Map<String, dynamic>;
        developer.log('Tecnicomecánica encontrada: ${jsonEncode(tecno)}');

        // Verificar si es "NO APLICA" (vehículos nuevos)
        final vigente = tecno['vigente'];
        if (vigente == 'NO APLICA') {
          result['tecnicomecanica'] = {
            'vigente': true, // Consideramos como vigente si no aplica
            'estado': 'NO APLICA',
            'fechaVencimiento': null,
          };
        } else {
          result['tecnicomecanica'] = {
            'vigente': vigente == 'SI',
            'estado': vigente ?? 'DESCONOCIDO',
            'fechaVencimiento': tecno['fechaVencimiento'],
            'fechaVigencia': tecno['fechaVigencia'],
            'certificado': tecno['certificado'],
            'cda': tecno['cda'],
          };
        }
      }
    }

    // Parsear información general del vehículo
    if (data.containsKey('informacionGeneral')) {
      final info = data['informacionGeneral'] as Map<String, dynamic>;
      developer.log('Información General encontrada: ${jsonEncode(info)}');

      result['vehiculo'] = {
        'placa': info['noPlaca'],
        'marca': info['marca'],
        'linea': info['linea'],
        'modelo': info['modelo'],
        'color': info['color'],
        'cilindraje': info['cilidraje'],
        'clase': info['claseVehiculo'],
        'servicio': info['tipoServicio'],
        'estado': info['estadoDelVehiculo'],
        'motor': info['noMotor'],
        'chasis': info['noChasis'],
        'vin': info['noVin'],
        'combustible': info['tipoCombustible'],
      };
    }

    developer.log('=== RESULTADO PARSEADO ===');
    developer.log(jsonEncode(result));

    return result;
  }
}
