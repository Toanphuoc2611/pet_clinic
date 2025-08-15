class CategoryDto {
  final int id;
  final String name;

  CategoryDto({required this.id, required this.name});
  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      CategoryDto(id: json['id'], name: json['name']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
