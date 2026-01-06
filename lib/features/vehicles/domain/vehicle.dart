class Vehicle {
  final String id;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String ownerDocumentType;
  final String ownerDocumentNumber;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.ownerDocumentType,
    required this.ownerDocumentNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      licensePlate: json['license_plate'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      ownerDocumentType: json['owner_document_type'] as String,
      ownerDocumentNumber: json['owner_document_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'owner_document_type': ownerDocumentType,
      'owner_document_number': ownerDocumentNumber,
    };
  }
}
