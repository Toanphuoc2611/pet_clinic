class LoginSuccessDto {
  final String token;
  LoginSuccessDto({required this.token});
  factory LoginSuccessDto.fromJson(Map<String, dynamic> json) {
    return LoginSuccessDto(token: json['token'] as String);
  }
}
