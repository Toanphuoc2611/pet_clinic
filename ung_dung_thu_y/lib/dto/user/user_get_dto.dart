class UserGetDto {
  final String id;
  final String? fullname;
  final String? birthday;
  final int? gender;
  final String phoneNumber;
  final String? address;
  final String? avatar;
  UserGetDto({
    required this.id,
    this.fullname,
    this.birthday,
    this.gender,
    required this.phoneNumber,
    this.address,
    this.avatar,
  });
  factory UserGetDto.fromJson(Map<String, dynamic> json) {
    return UserGetDto(
      id: json['id'],
      fullname: json['fullname'],
      birthday: json['birthday'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      avatar: json['avatar'],
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGetDto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
