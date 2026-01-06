import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_tracker/core/theme/app_theme.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/vehicles_provider.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/vehicle_runt_provider.dart';
import 'package:vehicle_tracker/features/shared/widgets/vehicle_header_widget.dart';
import 'package:vehicle_tracker/features/shared/widgets/alert_card_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: vehiclesAsync.maybeWhen(
          data: (vehicles) {
            if (vehicles.isEmpty || _selectedVehicle == null) {
              return const Text('Car Expenses');
            }
            // Dropdown para seleccionar vehículo
            return DropdownButton<Vehicle>(
              value: _selectedVehicle,
              underline: const SizedBox.shrink(),
              dropdownColor: isDark ? AppTheme.cardBackground : Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              items: vehicles.map((vehicle) {
                return DropdownMenuItem<Vehicle>(
                  value: vehicle,
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text('${vehicle.brand} ${vehicle.model}'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (vehicle) {
                if (vehicle != null) {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                }
              },
            );
          },
          orElse: () => const Text('Car Expenses'),
        ),
        actions: [
          // Botón de editar vehículo (solo visible si hay vehículo seleccionado)
          if (_selectedVehicle != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                context.push('/edit-vehicle', extra: _selectedVehicle!);
              },
              tooltip: 'Editar vehículo',
            ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, isDark),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          // Si no hay vehículo seleccionado, seleccionar el primero
          if (_selectedVehicle == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedVehicle = vehicles.first;
              });
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildVehicleDetails(context, _selectedVehicle!, isDark);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.accentRed,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(vehiclesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          vehiclesAsync.hasValue &&
              vehiclesAsync.value!.isNotEmpty &&
              _selectedVehicle != null
          ? _buildFloatingActionButtons(context)
          : null,
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón principal para agregar con micrófono (grande y naranja)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () {
                  // Navegar directo a la experiencia de voz
                  context.push(
                    '/quick-voice-expense',
                    extra: _selectedVehicle!.id,
                  );
                },
                child: const Center(
                  child: Icon(
                    Icons.mic_rounded,
                    size: 32,
                    color: AppTheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Botón secundario para agregar manualmente (más pequeño)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  // Navegar directo al formulario manual
                  context.push(
                    '/quick-manual-expense',
                    extra: _selectedVehicle!.id,
                  );
                },
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardBackground : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black26,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay vehículos',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primer vehículo para comenzar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/add-vehicle'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar Vehículo'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetails(
    BuildContext context,
    Vehicle vehicle,
    bool isDark,
  ) {
    final runtDataAsync = ref.watch(vehicleRuntProvider(vehicle));

    return RefreshIndicator(
      onRefresh: () async {
        try {
          final controller = VehicleRuntController(ref, vehicle);
          await controller.forceRefresh();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppTheme.accentRed,
              ),
            );
          }
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleHeaderWidget(vehicle: vehicle, isDark: isDark),
            const SizedBox(height: 24),
            _buildCacheInfo(context, runtDataAsync, vehicle, isDark),
            const SizedBox(height: 16),
            Text(
              'Alertas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            runtDataAsync.when(
              data: (state) {
                // Si hay error cacheado, mostrar empty state
                if (state.hasError) {
                  return _buildEmptyStateAlerts(context, isDark);
                }
                return _buildAlertsGrid(context, state.data, isDark);
              },
              loading: () => _buildLoadingAlerts(context, isDark),
              error: (err, stack) =>
                  _buildErrorCard(context, err.toString(), isDark),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, bool isDark) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.darkBackground, AppTheme.cardBackground]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Menú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Car Expenses',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Ver Gastos
                    if (_selectedVehicle != null)
                      _buildMenuTile(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: 'Ver Gastos',
                        subtitle: 'Historial de gastos del vehículo',
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            '/vehicle-details/expenses',
                            extra: _selectedVehicle!.id,
                          );
                        },
                        isDark: isDark,
                      ),

                    // Agregar Vehículo
                    _buildMenuTile(
                      context,
                      icon: Icons.add_circle_outline,
                      title: 'Agregar Vehículo',
                      subtitle: 'Registra un nuevo vehículo',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/add-vehicle');
                      },
                      isDark: isDark,
                    ),

                    const Divider(height: 32),

                    // Notificaciones
                    _buildMenuTile(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notificaciones',
                      subtitle: 'Alertas y recordatorios',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to notifications
                      },
                      isDark: isDark,
                    ),

                    // Configuración
                    _buildMenuTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                      subtitle: 'Preferencias de la app',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to settings
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: vehiclesAsync.maybeWhen(
                  data: (vehicles) => Text(
                    '${vehicles.length} ${vehicles.length == 1 ? 'vehículo registrado' : 'vehículos registrados'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCacheInfo(
    BuildContext context,
    AsyncValue<VehicleRuntState> runtDataAsync,
    Vehicle vehicle,
    bool isDark,
  ) {
    return runtDataAsync.when(
      data: (state) {
        if (state.cache == null) return const SizedBox.shrink();

        final lastFetched = state.cache!.lastFetched;
        final daysUntilRefresh = state.daysUntilNextRefresh();
        final canRefresh = state.canRefresh();
        final isError = state.hasError;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError
                ? AppTheme.accentRed.withValues(alpha: 0.1)
                : (isDark
                      ? AppTheme.cardBackground.withValues(alpha: 0.5)
                      : Colors.blue.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError
                  ? AppTheme.accentRed.withValues(alpha: 0.3)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.blue.shade200),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.info_outline
                    : (state.isFromCache ? Icons.cached : Icons.cloud_download),
                size: 20,
                color: isError
                    ? AppTheme.accentRed
                    : (isDark ? Colors.white70 : Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isError
                          ? 'No se encontró información en RUNT'
                          : (state.isFromCache
                                ? 'Datos en caché'
                                : 'Datos actualizados'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isError ? AppTheme.accentRed : null,
                      ),
                    ),
                    Text(
                      'Última consulta: ${DateFormat('dd MMM yyyy, HH:mm').format(lastFetched)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black54,
                      ),
                    ),
                    if (!canRefresh && daysUntilRefresh != null)
                      Text(
                        isError
                            ? 'Podrás consultar nuevamente mañana'
                            : 'Próximo refresh en $daysUntilRefresh días',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              if (canRefresh)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 20,
                  tooltip: isError ? 'Reintentar consulta' : 'Actualizar datos',
                  onPressed: () async {
                    try {
                      final controller = VehicleRuntController(ref, vehicle);
                      await controller.forceRefresh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos actualizados correctamente'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppTheme.accentRed,
                          ),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlertsGrid(
    BuildContext context,
    Map<String, dynamic> data,
    bool isDark,
  ) {
    final alerts = <Widget>[];

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

  Widget _buildEmptyStateAlerts(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildEmptyAlertCard(
          context,
          'SOAT',
          Icons.verified_user_rounded,
          isDark,
        ),
        _buildEmptyAlertCard(
          context,
          'Tecnicomecánica',
          Icons.build_circle_rounded,
          isDark,
        ),
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
      ],
    );
  }

  Widget _buildEmptyAlertCard(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Información no disponible',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          const Icon(
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
