class Expense {
  final String id;
  final String vehicleId;
  final String category; // Fuel, Maintenance, Taxes, etc.
  final double amount;
  final DateTime date;
  final String? description;

  // AI-related fields
  final double? aiConfidence;
  final String? originalTranscription;
  final bool parsedByAi;
  final String? aiModelVersion;

  Expense({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.aiConfidence,
    this.originalTranscription,
    this.parsedByAi = false,
    this.aiModelVersion,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      aiConfidence: json['ai_confidence'] != null
          ? (json['ai_confidence'] as num).toDouble()
          : null,
      originalTranscription: json['original_transcription'] as String?,
      parsedByAi: json['parsed_by_ai'] as bool? ?? false,
      aiModelVersion: json['ai_model_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'ai_confidence': aiConfidence,
      'original_transcription': originalTranscription,
      'parsed_by_ai': parsedByAi,
      'ai_model_version': aiModelVersion,
    };
  }
}
