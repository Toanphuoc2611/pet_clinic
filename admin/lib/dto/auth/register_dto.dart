class RegisterDto {
  String phoneNumber;
  String password;
  String address;
  String fullname;
  String birthday;
  int gender;
  String otp;

  RegisterDto({
    required this.phoneNumber,
    required this.password,
    required this.address,
    required this.fullname,
    required this.birthday,
    required this.gender,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
      'address': address,
      'fullname': fullname,
      'birthday': birthday,
      'gender': gender,
      'otp': otp,
    };
  }
}
