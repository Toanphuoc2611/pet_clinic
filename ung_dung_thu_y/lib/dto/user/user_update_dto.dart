class UserUpdateDto {
  final String id;
  final String? fullname;
  final String? birthday;
  final int? gender;
  final String? address;

  UserUpdateDto({
    required this.id,
    this.fullname,
    this.birthday,
    this.gender,
    this.address,
  });
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullname": fullname,
      "birthday": birthday,
      "gender": gender,
      "address": address,
    };
  }
}
