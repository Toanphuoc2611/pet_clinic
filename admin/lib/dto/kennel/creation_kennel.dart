class CreationKennel {
  final String name;
  final String type;
  final double priceMultiplier;

  CreationKennel({
    required this.name,
    required this.type,
    required this.priceMultiplier,
  });

  factory CreationKennel.fromJson(Map<String, dynamic> json) => CreationKennel(
    name: json['name'],
    type: json['type'],
    priceMultiplier: json['priceMultiplier']?.toDouble() ?? 1.0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'multi': priceMultiplier,
  };
}
