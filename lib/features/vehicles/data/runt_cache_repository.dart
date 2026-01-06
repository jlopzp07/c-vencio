import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:c_vencio/features/vehicles/domain/vehicle_runt_cache.dart';
import 'dart:developer' as developer;

final runtCacheRepositoryProvider = Provider((ref) => RuntCacheRepository());

class RuntCacheRepository {
  final _supabase = Supabase.instance.client;

  /// Obtiene el caché de RUNT para un vehículo
  Future<VehicleRuntCache?> getCacheForVehicle(String vehicleId) async {
    try {
      developer.log('Obteniendo caché para vehículo: $vehicleId');

      final response = await _supabase
          .from('vehicle_runt_cache')
          .select()
          .eq('vehicle_id', vehicleId)
          .maybeSingle();

      if (response == null) {
        developer.log('No se encontró caché para el vehículo');
        return null;
      }

      return VehicleRuntCache.fromJson(response);
    } catch (e) {
      developer.log('Error obteniendo caché: $e');
      return null;
    }
  }

  /// Guarda o actualiza el caché de RUNT para un vehículo
  Future<void> saveCache(VehicleRuntCache cache) async {
    try {
      developer.log('Guardando caché para vehículo: ${cache.vehicleId}');

      await _supabase.from('vehicle_runt_cache').upsert(
        cache.toJson(),
        onConflict: 'vehicle_id',
      );

      developer.log('Caché guardado exitosamente');
    } catch (e) {
      developer.log('Error guardando caché: $e');
      rethrow;
    }
  }

  /// Elimina el caché de un vehículo
  Future<void> deleteCache(String vehicleId) async {
    try {
      await _supabase
          .from('vehicle_runt_cache')
          .delete()
          .eq('vehicle_id', vehicleId);
    } catch (e) {
      developer.log('Error eliminando caché: $e');
    }
  }
}
