import 'package:ung_dung_thu_y/dto/appointment/appointment_creation.dart';

class AppointmentEvent {}

class AppointmentGetStarted extends AppointmentEvent {
  final String status;
  AppointmentGetStarted(this.status);
}

class GetScheduleByDoctorStarted extends AppointmentEvent {
  final String doctorId;
  GetScheduleByDoctorStarted(this.doctorId);
}

class AppointmentCreationStarted extends AppointmentEvent {
  final AppointmentCreation appointmentCreation;
  AppointmentCreationStarted(this.appointmentCreation);
}
