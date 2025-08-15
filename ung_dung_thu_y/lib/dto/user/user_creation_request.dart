class UserCreationRequest {
  final String fullname;
  final String birthday;
  final String phoneNumber;
  final int gender;
  final String address;

  UserCreationRequest({
    required this.fullname,
    required this.birthday,
    required this.phoneNumber,
    required this.gender,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'birthday': birthday,
      'phone_number': phoneNumber,
      'gender': gender,
      'address': address,
    };
  }

  factory UserCreationRequest.fromJson(Map<String, dynamic> json) {
    return UserCreationRequest(
      fullname: json['fullname'],
      birthday: json['birthday'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      address: json['address'],
    );
  }
}
