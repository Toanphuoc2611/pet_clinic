import 'package:admin/dto/user/user_get_dto.dart';

class AccountDto {
  final int id;
  final UserGetDto user;
  final String email;
  final int status;
  final String role;

  AccountDto({
    required this.id,
    required this.user,
    required this.email,
    required this.status,
    required this.role,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) => AccountDto(
    id: json['id'],
    user: UserGetDto.fromJson(json['user']),
    email: json['email'],
    status: json['status'],
    role: json['role']['name'],
  );
}
