import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_tracker/features/vehicles/data/vehicle_data_service.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/features/shared/widgets/vehicle_header_widget.dart';
import 'package:vehicle_tracker/features/shared/widgets/alert_card_widget.dart';
import 'package:go_router/go_router.dart';

final vehicleStatusProvider =
    FutureProvider.family<Map<String, dynamic>, Vehicle>((ref, vehicle) async {
      final service = ref.read(vehicleDataServiceProvider);
      return service.getVehicleData(
        licensePlate: vehicle.licensePlate,
        ownerDocType: vehicle.ownerDocumentType,
        ownerDocNumber: vehicle.ownerDocumentNumber,
      );
    });

class VehicleDetailsScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(vehicleStatusProvider(vehicle));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.brand} ${vehicle.model}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push('/edit-vehicle', extra: vehicle);
            },
            tooltip: 'Editar vehículo',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleHeaderWidget(vehicle: vehicle, isDark: isDark),
            const SizedBox(height: 24),
            Text(
              'Alertas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            statusAsync.when(
              data: (data) => _buildAlertsGrid(context, data, isDark),
              loading: () => _buildLoadingAlerts(context, isDark),
              error: (err, stack) =>
                  _buildErrorCard(context, err.toString(), isDark),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(
                  '/vehicle-details/expenses',
                  extra: vehicle.id,
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Ver Gastos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsGrid(
    BuildContext context,
    Map<String, dynamic> data,
    bool isDark,
  ) {
    final alerts = <Widget>[];

    // Check SOAT
    if (data.containsKey('soat')) {
      alerts.add(
        AlertCardWidget(
          title: 'SOAT',
          data: data['soat'],
          icon: Icons.verified_user_rounded,
          isDark: isDark,
        ),
      );
    }

    // Check Tecnicomecánica
    if (data.containsKey('tecnicomecanica')) {
      alerts.add(
        AlertCardWidget(
          title: 'Tecnicomecánica',
          data: data['tecnicomecanica'],
          icon: Icons.build_circle_rounded,
          isDark: isDark,
        ),
      );
    }

    // Add placeholder alerts
    alerts.addAll([
      _buildPlaceholderAlert(
        context,
        'Licencia de conducir',
        Icons.credit_card_rounded,
        isDark,
      ),
      _buildPlaceholderAlert(
        context,
        'Seguro todo riesgo',
        Icons.shield_rounded,
        isDark,
      ),
      _buildPlaceholderAlert(context, 'Llantas', Icons.album_rounded, isDark),
      _buildPlaceholderAlert(
        context,
        'Cambio de aceite',
        Icons.oil_barrel_rounded,
        isDark,
      ),
    ]);

    if (alerts.isEmpty) {
      return Text(
        'No hay datos de alertas disponibles.',
        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: alerts,
    );
  }

  Widget _buildPlaceholderAlert(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    return AlertCardWidget(
      title: title,
      data: {'vigente': true},
      icon: icon,
      isDark: isDark,
    );
  }

  Widget _buildLoadingAlerts(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.accentRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al verificar estado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifica que tu API Key de Verifik esté configurada correctamente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
