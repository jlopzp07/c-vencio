import 'package:equatable/equatable.dart';

/// Representación de un gasto parseado por AI desde entrada de voz
class AiParsedExpense extends Equatable {
  /// Monto del gasto
  final double? amount;

  /// Categoría detectada
  final String? category;

  /// Descripción/nota del gasto
  final String? description;

  /// Nivel de confianza del parsing (0.0 - 1.0)
  final double confidence;

  /// Texto original de la transcripción
  final String originalText;

  /// ID del vehículo si se detectó
  final String? vehicleId;

  /// Fecha detectada (por defecto: hoy)
  final DateTime date;

  AiParsedExpense({
    this.amount,
    this.category,
    this.description,
    required this.confidence,
    required this.originalText,
    this.vehicleId,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  /// Indica si el parsing fue exitoso (tiene al menos monto y categoría)
  bool get isValid => amount != null && category != null;

  /// Categorías válidas de gastos
  static const List<String> validCategories = [
    'Fuel',           // Combustible
    'Maintenance',    // Mantenimiento
    'Insurance',      // Seguro
    'Parking',        // Estacionamiento
    'Tolls',          // Peajes
    'Repairs',        // Reparaciones
    'Cleaning',       // Lavado
    'Accessories',    // Accesorios
    'Other',          // Otros
  ];

  /// Crea una copia con campos modificados
  AiParsedExpense copyWith({
    double? amount,
    String? category,
    String? description,
    double? confidence,
    String? originalText,
    String? vehicleId,
    DateTime? date,
  }) {
    return AiParsedExpense(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      originalText: originalText ?? this.originalText,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
        amount,
        category,
        description,
        confidence,
        originalText,
        vehicleId,
        date,
      ];

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'confidence': confidence,
      'originalText': originalText,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
    };
  }

  factory AiParsedExpense.fromJson(Map<String, dynamic> json) {
    return AiParsedExpense(
      amount: json['amount'] as double?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      confidence: json['confidence'] as double,
      originalText: json['originalText'] as String,
      vehicleId: json['vehicleId'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
