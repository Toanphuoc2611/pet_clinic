import 'package:admin/dto/user/user_get_dto.dart';

class UserResponse {
  final UserGetDto user;
  final int balance;

  UserResponse({required this.user, required this.balance});

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    user: UserGetDto.fromJson(json['user']),
    balance: json['balance'],
  );
}
