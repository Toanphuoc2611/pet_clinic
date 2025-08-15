import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';

sealed class AppointmentState {}

// Get Appointment state
class AppointmentGetInitital extends AppointmentState {}

class AppointmentGetInProgress extends AppointmentState {}

class AppointmentGetSuccess extends AppointmentState {
  List<AppointmentGetDto> appointments;
  AppointmentGetSuccess(this.appointments);
}

// Get Doctor's schedule state
class GeScheduleByDoctorInProgress extends AppointmentState {}

class GetScheduleByDoctorSuccess extends AppointmentState {
  final List<String> schedules;
  GetScheduleByDoctorSuccess(this.schedules);
}

// Create appointment state
class AppointmentCreationInProgress extends AppointmentState {}

class AppointmentCreationSuccess extends AppointmentState {
  final bool isSuccess;
  AppointmentCreationSuccess(this.isSuccess);
}

// Appointment state error
class AppointmentFailure extends AppointmentState {
  final String message;
  AppointmentFailure(this.message);
}
