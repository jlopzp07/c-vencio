import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/features/shared/widgets/info_chip_widget.dart';

/// Widget reutilizable para mostrar el encabezado de un vehículo
/// con su imagen, marca, modelo, placa y chips de información.
class VehicleHeaderWidget extends StatelessWidget {
  final Vehicle vehicle;
  final bool isDark;

  const VehicleHeaderWidget({
    super.key,
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.cardBackground,
                  AppTheme.cardBackground.withValues(alpha: 0.8),
                ]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.15),
            ),
            child: Image.network(
              'https://api.dicebear.com/7.x/shapes/png?seed=${vehicle.licensePlate}',
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car_rounded,
                size: 60,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.licensePlate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InfoChipWidget(
                      icon: Icons.calendar_today,
                      label: vehicle.year.toString(),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    InfoChipWidget(
                      icon: Icons.palette_outlined,
                      label: vehicle.color,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
