import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';

sealed class DoctorAppointmentState {}

class DoctorAppointmentInitial extends DoctorAppointmentState {}

class DoctorAppointmentGetTodayInProgress extends DoctorAppointmentState {}

class DoctorAppointmentGetTodaySuccess extends DoctorAppointmentState {
  final List<AppointmentGetDto> appointments;
  DoctorAppointmentGetTodaySuccess(this.appointments);
}

class DoctorAppointmentGetTodayFailure extends DoctorAppointmentState {
  final String message;
  DoctorAppointmentGetTodayFailure({required this.message});
}
