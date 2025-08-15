import 'package:admin/dto/medication/medication_dto.dart';

class InventoryDto {
  final int id;
  final int quantity;
  final int price;
  final int soldOut;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MedicationDto medication;

  InventoryDto({
    required this.id,
    required this.quantity,
    required this.price,
    required this.soldOut,
    required this.createdAt,
    required this.updatedAt,
    required this.medication,
  });

  factory InventoryDto.fromJson(Map<String, dynamic> json) {
    return InventoryDto(
      id: json['id'],
      quantity: json['quantity'],
      price: json['price'],
      soldOut: json['soldOut'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      medication: MedicationDto.fromJson(json['medication']),
    );
  }
}
