import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/vehicles_provider.dart';
import 'package:uuid/uuid.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _ownerDocTypeController = TextEditingController(text: 'CC'); // Default
  final _ownerDocNumController = TextEditingController();

  bool _isLoading = false;

  void _showDocumentTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Cédula de Ciudadanía (CC)'),
              onTap: () {
                setState(() => _ownerDocTypeController.text = 'CC');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('NIT'),
              onTap: () {
                setState(() => _ownerDocTypeController.text = 'NIT');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_travel_outlined),
              title: const Text('Cédula de Extranjería (CE)'),
              onTap: () {
                setState(() => _ownerDocTypeController.text = 'CE');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.child_care_outlined),
              title: const Text('Tarjeta de Identidad (TI)'),
              onTap: () {
                setState(() => _ownerDocTypeController.text = 'TI');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _ownerDocTypeController.dispose();
    _ownerDocNumController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vehicle = Vehicle(
        id: const Uuid().v4(), // Generate ID locally for now, Supabase can handle it too
        licensePlate: _plateController.text.toUpperCase(),
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        color: _colorController.text,
        ownerDocumentType: _ownerDocTypeController.text,
        ownerDocumentNumber: _ownerDocNumController.text,
      );

      await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding vehicle: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vehículo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFFEB1555).withValues(alpha: 0.15)
                        : const Color(0xFFEB1555).withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 64,
                    color: Color(0xFFEB1555),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // License Plate
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'ABC-123',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // Brand and Model
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        hintText: 'Renault',
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        hintText: 'Clio',
                        prefixIcon: Icon(Icons.model_training_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Year and Color
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        hintText: '2023',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return 'Año inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'Blanco',
                        prefixIcon: Icon(Icons.palette_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Owner Information Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D1E33).withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información del Propietario',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requerido para consultas RUNT',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        TextFormField(
                          controller: _ownerDocTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Documento',
                            prefixIcon: Icon(Icons.badge_outlined),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          readOnly: true,
                          onTap: _showDocumentTypeBottomSheet,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ownerDocNumController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Documento',
                            hintText: '1234567890',
                            prefixIcon: Icon(Icons.numbers_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              FilledButton(
                onPressed: _isLoading ? null : _saveVehicle,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 24),
                          SizedBox(width: 8),
                          Text('Guardar Vehículo', style: TextStyle(fontSize: 16)),
                        ],
                      ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
