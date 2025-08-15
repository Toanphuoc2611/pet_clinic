class DoctorAppointmentEvent {}

class DoctorAppointmentGetStarted extends DoctorAppointmentEvent {
  final String date;
  DoctorAppointmentGetStarted(this.date);
}
