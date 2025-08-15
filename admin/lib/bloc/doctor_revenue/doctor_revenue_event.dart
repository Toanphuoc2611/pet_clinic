class DoctorRevenueEvent {}

class DoctorRevenueGetStarted extends DoctorRevenueEvent {
  final String start;
  final String end;
  final String doctorId;

  DoctorRevenueGetStarted(this.start, this.end, this.doctorId);
}

class DoctorRevenueResetEvent extends DoctorRevenueEvent {}
