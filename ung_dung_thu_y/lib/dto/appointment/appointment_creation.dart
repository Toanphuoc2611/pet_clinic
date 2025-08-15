import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';

class AppointmentCreation {
  final String doctorId;
  final List<ServicesGetDto> services;
  final String appointmentTime;
  final int? status;
  AppointmentCreation({
    required this.doctorId,
    required this.services,
    required this.appointmentTime,
    this.status,
  });
  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'services': services.map((s) => s.toJson()).toList(),
      'appointmentTime': appointmentTime,
      'status': status ?? 0,
    };
  }
}
