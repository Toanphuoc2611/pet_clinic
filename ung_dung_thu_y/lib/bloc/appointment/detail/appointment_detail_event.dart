class AppointmentDetailEvent {}

class AppointmentDetailGetStarted extends AppointmentDetailEvent {
  final int appointmentId;
  AppointmentDetailGetStarted(this.appointmentId);
}

class AppointmentDetailUpdateStarted extends AppointmentDetailEvent {
  final int appointmentId;
  AppointmentDetailUpdateStarted(this.appointmentId);
}
