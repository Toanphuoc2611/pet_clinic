class Province {
  int id;
  String name;
  Province({required this.id, required this.name});
  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['ProvinceID'] as int,
      name: json['ProvinceName'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {'ProvinceID': id, 'ProvinceName': name};
  }
}
