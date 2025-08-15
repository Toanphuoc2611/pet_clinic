class KennelDto {
  final int id;
  final String name;
  final String type;
  final double priceMultiplier;

  KennelDto({
    required this.id,
    required this.name,
    required this.type,
    required this.priceMultiplier,
  });

  factory KennelDto.fromJson(Map<String, dynamic> json) => KennelDto(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    priceMultiplier: json['priceMultiplier']?.toDouble() ?? 1.0,
  );
}
