import 'package:admin/dto/medication/category_dto.dart';

class MedicationDto {
  final int id;
  final String name;
  final String description;
  final String unit;
  final int price;
  final int stockQuantity;
  final CategoryDto category;
  final int isSale;

  MedicationDto({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.stockQuantity,
    required this.category,
    this.isSale = 1,
  });

  factory MedicationDto.fromJson(Map<String, dynamic> json) {
    return MedicationDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unit: json['unit'],
      price: json['price'],
      stockQuantity: json['stockQuantity'],
      category: CategoryDto.fromJson(json['category']),
      isSale: json['isSale'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'unit': unit,
    'price': price,
    'stockQuantity': stockQuantity,
    'category': category.toJson(),
    'isSale': isSale,
  };
}
