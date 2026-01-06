class VehicleRuntCache {
  final String vehicleId;
  final Map<String, dynamic> runtData;
  final DateTime lastFetched;
  final bool hasError;
  final String? errorMessage;

  VehicleRuntCache({
    required this.vehicleId,
    required this.runtData,
    required this.lastFetched,
    this.hasError = false,
    this.errorMessage,
  });

  /// Verifica si se puede refrescar el caché
  /// - Errores: 1 día de espera
  /// - Datos exitosos: 30 días de espera
  bool canRefresh() {
    final now = DateTime.now();
    final difference = now.difference(lastFetched);
    final daysRequired = hasError ? 1 : 30;
    return difference.inDays >= daysRequired;
  }

  int daysUntilNextRefresh() {
    final now = DateTime.now();
    final difference = now.difference(lastFetched);
    final daysRequired = hasError ? 1 : 30;
    final daysRemaining = daysRequired - difference.inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  factory VehicleRuntCache.fromJson(Map<String, dynamic> json) {
    return VehicleRuntCache(
      vehicleId: json['vehicle_id'] as String,
      runtData: json['runt_data'] as Map<String, dynamic>,
      lastFetched: DateTime.parse(json['last_fetched'] as String),
      hasError: json['has_error'] as bool? ?? false,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'runt_data': runtData,
      'last_fetched': lastFetched.toIso8601String(),
      'has_error': hasError,
      'error_message': errorMessage,
    };
  }
}
