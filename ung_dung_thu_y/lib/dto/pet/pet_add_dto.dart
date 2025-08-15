class PetAddDto {
  final String? id;
  final String name;
  final String? birthday;
  final String? type;
  final String? breed;
  final String? color;
  final int gender; // 0: male, 1: female
  final double weight;
  final int isNeutered; // 0: false, 1: true
  final String? note;
  final String? userId;

  PetAddDto({
    this.id,
    required this.name,
    this.birthday,
    this.type,
    this.breed,
    this.color,
    this.gender = 0,
    this.weight = 0.0,
    this.isNeutered = 0,
    this.note,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'type': type,
      'breed': breed,
      'color': color,
      'gender': gender,
      'weight': weight,
      'is_neutered': isNeutered,
      'note': note,
      'userId': userId,
    };
  }
}
