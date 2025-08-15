class PetUpdateDto {
  final String breed;
  final double weight;
  final int isNeutered;
  final String note;
  PetUpdateDto({
    required this.breed,
    required this.weight,
    required this.isNeutered,
    required this.note,
  });
  Map<String, dynamic> toJson() {
    return {
      'breed': breed,
      'weight': weight,
      'isNeutered': isNeutered,
      'note': note,
    };
  }
}
