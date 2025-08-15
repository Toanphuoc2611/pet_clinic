class CreationService {
  final String name;
  final int price;
  CreationService({required this.name, required this.price});
  factory CreationService.fromJson(Map<String, dynamic> json) {
    // Đảm bảo chuyển đổi price từ dynamic sang int
    int parsedPrice = 0;
    if (json['price'] != null) {
      if (json['price'] is int) {
        parsedPrice = json['price'];
      } else if (json['price'] is String) {
        parsedPrice = int.tryParse(json['price']) ?? 0;
      }
    }
    return CreationService(name: json['name'], price: parsedPrice);
  }
  Map<String, dynamic> toJson() {
    // Đảm bảo price được chuyển đổi thành số nguyên
    return {'name': name, 'price': price};
  }
}
