class InvoiceEvent {}

class InvoiceGetRevenueStarted extends InvoiceEvent {
  final String start;
  final String end;
  InvoiceGetRevenueStarted(this.start, this.end);
}

class InvoiceGetRevenueByDoctorStarted extends InvoiceEvent {
  final String start;
  final String end;
  final String doctorId;
  InvoiceGetRevenueByDoctorStarted(this.start, this.end, this.doctorId);
}
