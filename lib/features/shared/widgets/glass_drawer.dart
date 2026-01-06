import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/core/theme/design_tokens.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';

/// Drawer con efecto glassmorphism para la navegación de vehículos
class GlassDrawer extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final Function(Vehicle) onVehicleSelected;
  final VoidCallback onAddVehicle;
  final bool isDark;

  const GlassDrawer({
    super.key,
    required this.vehicles,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    required this.onAddVehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppTheme.darkBackground.withValues(alpha: 0.95),
                    AppTheme.cardBackground.withValues(alpha: 0.95),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.grey.shade50.withValues(alpha: 0.95),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildVehicleList(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles with glassmorphism
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMedium,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceM),
                const Text(
                  'Mis Vehículos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  '${vehicles.length} ${vehicles.length == 1 ? 'vehículo' : 'vehículos'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    if (vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_filled_outlined,
                size: 64,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black26,
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Text(
                'No hay vehículos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceS),
              Text(
                'Agrega tu primer vehículo\npara comenzar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final isSelected = selectedVehicle?.id == vehicle.id;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceXS,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isSelected ? 10 : 0,
                sigmaY: isSelected ? 10 : 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.5)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceM,
                    vertical: DesignTokens.spaceXS,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceS),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: isSelected ? AppTheme.primary : null,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? AppTheme.primary : null,
                    ),
                  ),
                  subtitle: Text(
                    vehicle.licensePlate,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black54,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    onVehicleSelected(vehicle);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(DesignTokens.radiusMedium),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                margin: const EdgeInsets.all(DesignTokens.spaceM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.8),
                      AppTheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onAddVehicle();
                    },
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMedium,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceL,
                        vertical: DesignTokens.spaceM,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceXS),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceS),
                          const Text(
                            'Agregar Vehículo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceS),
        ],
      ),
    );
  }
}
