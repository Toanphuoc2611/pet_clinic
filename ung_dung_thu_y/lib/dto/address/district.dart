class District {
  final int id;
  final int idProvince;
  final String name;

  District({required this.id, required this.idProvince, required this.name});
  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['districtID'] as int,
      idProvince: json['provinceID'] as int,
      name: json['districtName'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {'districtID': id, 'provinceID': idProvince, 'districtName': name};
  }
}
