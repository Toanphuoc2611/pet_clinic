import 'package:ung_dung_thu_y/dto/auth/register_dto.dart';

abstract class AuthEvent {}

class AuthLoginStarted extends AuthEvent {
  final String phoneNumber;
  final String password;
  AuthLoginStarted({required this.phoneNumber, required this.password});
}

class AuthRegisterStarted extends AuthEvent {
  final RegisterDto registerDto;
  AuthRegisterStarted(this.registerDto);
}

class AuthsendOtpStarted extends AuthEvent {
  final String phoneNumber;
  AuthsendOtpStarted(this.phoneNumber);
}

class AuthLogoutStarted extends AuthEvent {}
