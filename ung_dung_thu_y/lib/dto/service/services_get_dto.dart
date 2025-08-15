class ServicesGetDto {
  final int? id;
  final String name;
  final int price;
  ServicesGetDto({this.id, required this.name, required this.price});
  factory ServicesGetDto.fromJson(Map<String, dynamic> json) {
    return ServicesGetDto(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }
}
