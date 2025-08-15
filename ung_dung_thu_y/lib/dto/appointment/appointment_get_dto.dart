import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class AppointmentGetDto {
  final int id;
  final String fullname;
  final UserGetDto user;
  final String? avatar;
  final String phoneNumberDoctor;
  final String appointmentTime;
  final int status;
  final List<ServicesGetDto> services;
  AppointmentGetDto({
    required this.id,
    required this.fullname,
    required this.user,
    this.avatar,
    required this.phoneNumberDoctor,
    required this.appointmentTime,
    required this.status,
    required this.services,
  });

  factory AppointmentGetDto.fromJson(Map<String, dynamic> json) {
    return AppointmentGetDto(
      id: json['id'],
      fullname: json['doctor']['fullname'],
      user: UserGetDto.fromJson(json['user']),
      avatar: json['doctor']['avatar'],
      phoneNumberDoctor: json['doctor']['phoneNumber'],
      appointmentTime: json['appointmentTime'],
      status: json['status'] ?? 0,
      services:
          (json['services'] as List<dynamic>)
              .map((e) => ServicesGetDto.fromJson(e))
              .toList(),
    );
  }
}
