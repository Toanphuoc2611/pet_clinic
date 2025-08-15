import 'package:admin/dto/appointment/appointment_get_dto.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentGetInProgress extends AppointmentState {}

class AppointmentGetWeeklySuccess extends AppointmentState {
  final List<AppointmentGetDto> appointments;
  final String startDate;
  AppointmentGetWeeklySuccess(this.appointments, this.startDate);
}

class AppointmentGetFailure extends AppointmentState {
  final String message;
  AppointmentGetFailure(this.message);
}
