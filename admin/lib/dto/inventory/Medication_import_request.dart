class MedicationImportRequest {
  final String name;
  final String description;
  final String unit;
  final int price;
  final int quantity;
  final int categoryId;

  MedicationImportRequest({
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
    };
  }
}
