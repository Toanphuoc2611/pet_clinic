class KennelDto {
  final int id;
  final String name;
  final String type;
  final double priceMultiplier;
  final int? status; // 1 = bình thường, 2 = ngưng sử dụng

  KennelDto({
    required this.id,
    required this.name,
    required this.type,
    required this.priceMultiplier,
    this.status,
  });

  factory KennelDto.fromJson(Map<String, dynamic> json) => KennelDto(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    priceMultiplier: json['priceMultiplier']?.toDouble() ?? 1.0,
    status: json['status'],
  );
}
