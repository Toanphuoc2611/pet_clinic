class CreateDoctorRequest {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? birthday;
  final int? gender;

  CreateDoctorRequest({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.birthday,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    };

    if (birthday != null) {
      data['birthday'] = birthday;
    }

    if (gender != null) {
      data['gender'] = gender;
    }

    return data;
  }
}
