class ImportInventory {
  final int medicationId;
  final int quantity;
  final int price;

  ImportInventory({
    required this.medicationId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {'medicationId': medicationId, 'quantity': quantity, 'price': price};
  }
}
