import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';

final vehicleRepositoryProvider = Provider((ref) => VehicleRepository());

class VehicleRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Vehicle>> getVehicles() async {
    // TODO: Remove mock when Supabase is configured
    // return [
    //   Vehicle(
    //     id: '1',
    //     licensePlate: 'ABC-123',
    //     brand: 'Toyota',
    //     model: 'Corolla',
    //     year: 2020,
    //     color: 'White',
    //     ownerDocumentType: 'CC',
    //     ownerDocumentNumber: '123456789',
    //   ),
    // ];
    
    final response = await _supabase.from('vehicles').select();
    return (response as List).map((e) => Vehicle.fromJson(e)).toList();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _supabase.from('vehicles').insert(vehicle.toJson());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _supabase.from('vehicles').update(vehicle.toJson()).eq('id', vehicle.id);
  }

  Future<void> deleteVehicle(String id) async {
    await _supabase.from('vehicles').delete().eq('id', id);
  }
}
