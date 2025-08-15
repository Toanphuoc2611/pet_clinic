class InvoiceKennelEvent {}

class InvoiceKennelGetRevenueStarted extends InvoiceKennelEvent {
  final String start;
  final String end;
  InvoiceKennelGetRevenueStarted(this.start, this.end);
}

class InvoiceKennelGetRevenueByDoctorStarted extends InvoiceKennelEvent {
  final String start;
  final String end;
  final String doctorId;
  InvoiceKennelGetRevenueByDoctorStarted(this.start, this.end, this.doctorId);
}
