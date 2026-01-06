import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';

final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    return _fetchVehicles();
  }

  Future<List<Vehicle>> _fetchVehicles() async {
    final repository = ref.read(vehicleRepositoryProvider);
    return repository.getVehicles();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final repository = ref.read(vehicleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.addVehicle(vehicle);
      return _fetchVehicles();
    });
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final repository = ref.read(vehicleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateVehicle(vehicle);
      return _fetchVehicles();
    });
  }

  Future<void> deleteVehicle(String id) async {
    final repository = ref.read(vehicleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteVehicle(id);
      return _fetchVehicles();
    });
  }
}
