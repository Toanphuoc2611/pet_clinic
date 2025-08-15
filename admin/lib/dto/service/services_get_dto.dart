class ServicesGetDto {
  final int? id;
  final String name;
  final int price;
  final int status;
  ServicesGetDto({
    this.id,
    required this.name,
    required this.price,
    required this.status,
  });
  factory ServicesGetDto.fromJson(Map<String, dynamic> json) {
    return ServicesGetDto(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'status': status};
  }
}
