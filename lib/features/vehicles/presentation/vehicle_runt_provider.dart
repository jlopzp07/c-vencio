import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/vehicles/data/runt_cache_repository.dart';
import 'package:vehicle_tracker/features/vehicles/data/vehicle_data_service.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle_runt_cache.dart';
import 'dart:developer' as developer;

/// Estado del RUNT que incluye los datos y el caché
class VehicleRuntState {
  final Map<String, dynamic> data;
  final VehicleRuntCache? cache;
  final bool isFromCache;

  VehicleRuntState({
    required this.data,
    this.cache,
    required this.isFromCache,
  });

  bool canRefresh() {
    if (cache == null) return true;
    return cache!.canRefresh();
  }

  int? daysUntilNextRefresh() {
    if (cache == null) return null;
    return cache!.daysUntilNextRefresh();
  }

  /// Indica si este estado representa un error cacheado
  bool get hasError => cache?.hasError ?? false;

  /// Mensaje de error si existe
  String? get errorMessage => cache?.errorMessage;
}

/// Provider que gestiona los datos RUNT de un vehículo con caché
/// IMPORTANTE: Sin autoDispose para evitar múltiples llamadas a la API
final vehicleRuntProvider = FutureProvider.family<VehicleRuntState, Vehicle>((ref, vehicle) async {
  // Mantener el provider vivo para evitar llamadas múltiples
  ref.keepAlive();
  final cacheRepo = ref.read(runtCacheRepositoryProvider);
  final dataService = ref.read(vehicleDataServiceProvider);

  developer.log('=== INICIANDO CONSULTA RUNT PARA ${vehicle.licensePlate} ===');

  // Intentar obtener del caché primero
  final cache = await cacheRepo.getCacheForVehicle(vehicle.id);

  if (cache != null) {
    developer.log('Caché encontrado. Última actualización: ${cache.lastFetched}');
    developer.log('Puede refrescar: ${cache.canRefresh()}');

    // Si el caché es válido (menos de 30 días), retornarlo
    if (!cache.canRefresh()) {
      developer.log('Usando datos del caché (válido por ${cache.daysUntilNextRefresh()} días más)');
      return VehicleRuntState(
        data: cache.runtData,
        cache: cache,
        isFromCache: true,
      );
    }

    developer.log('Caché expirado, consultando API...');
  } else {
    developer.log('No se encontró caché, consultando API...');
  }

  // Si no hay caché o está expirado, consultar la API
  try {
    final data = await dataService.getVehicleData(
      licensePlate: vehicle.licensePlate,
      ownerDocType: vehicle.ownerDocumentType,
      ownerDocNumber: vehicle.ownerDocumentNumber,
    );

    // Guardar en caché exitoso
    final newCache = VehicleRuntCache(
      vehicleId: vehicle.id,
      runtData: data,
      lastFetched: DateTime.now(),
      hasError: false,
      errorMessage: null,
    );

    await cacheRepo.saveCache(newCache);
    developer.log('✅ Datos exitosos guardados en caché');

    return VehicleRuntState(
      data: data,
      cache: newCache,
      isFromCache: false,
    );
  } catch (e) {
    developer.log('❌ Error consultando API: $e');

    // NUEVO: Cachear el error para evitar múltiples llamadas
    final errorCache = VehicleRuntCache(
      vehicleId: vehicle.id,
      runtData: {},
      lastFetched: DateTime.now(),
      hasError: true,
      errorMessage: e.toString(),
    );

    await cacheRepo.saveCache(errorCache);
    developer.log('💾 Error cacheado (válido por 1 día)');

    // Retornar estado con error cacheado
    return VehicleRuntState(
      data: {},
      cache: errorCache,
      isFromCache: true,
    );
  }
});

/// Controlador para manejar el refresh manual
class VehicleRuntController {
  final WidgetRef ref;
  final Vehicle vehicle;

  VehicleRuntController(this.ref, this.vehicle);

  Future<void> forceRefresh() async {
    // Obtener el estado actual
    final currentStateAsync = ref.read(vehicleRuntProvider(vehicle));

    await currentStateAsync.when(
      data: (currentState) async {
        // Verificar si se puede refrescar
        if (!currentState.canRefresh()) {
          throw Exception(
            'Solo puedes refrescar los datos cada 30 días. '
            'Próximo refresh disponible en ${currentState.daysUntilNextRefresh()} días.',
          );
        }

        // Invalidar el provider para forzar una nueva consulta
        ref.invalidate(vehicleRuntProvider(vehicle));
      },
      loading: () async {
        throw Exception('Ya hay una consulta en progreso');
      },
      error: (e, s) async {
        // Si hay error, permitir refrescar
        ref.invalidate(vehicleRuntProvider(vehicle));
      },
    );
  }
}
