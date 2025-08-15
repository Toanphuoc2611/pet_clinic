abstract class AppointmentEvent {}

class AppointmentGetWeeklyStarted extends AppointmentEvent {
  final String startDate;
  AppointmentGetWeeklyStarted(this.startDate);
}
