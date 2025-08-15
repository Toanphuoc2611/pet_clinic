class Ward {
  final String code;
  final int districtId;
  final String name;
  Ward({required this.code, required this.districtId, required this.name});
  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['wardCode'] as String,
      districtId: json['districtID'] as int,
      name: json['wardName'] as String,
    );
  }
}
