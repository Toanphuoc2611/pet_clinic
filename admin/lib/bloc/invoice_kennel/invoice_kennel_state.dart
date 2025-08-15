sealed class InvoiceKennelState {}

class InvoiceKennelInitial extends InvoiceKennelState {}

class InvoiceKennelGetRevenueInProgress extends InvoiceKennelState {}

class InvoiceKennelGetRevenueSuccess extends InvoiceKennelState {
  final int revenue;
  InvoiceKennelGetRevenueSuccess(this.revenue);
}

class InvoiceKennelGetRevenueFailure extends InvoiceKennelState {
  final String message;
  InvoiceKennelGetRevenueFailure(this.message);
}

class InvoiceKennelGetRevenueByDoctorInProgress extends InvoiceKennelState {}

class InvoiceKennelGetRevenueByDoctorSuccess extends InvoiceKennelState {
  final int revenue;
  InvoiceKennelGetRevenueByDoctorSuccess(this.revenue);
}

class InvoiceKennelGetRevenueByDoctorFailure extends InvoiceKennelState {
  final String message;
  InvoiceKennelGetRevenueByDoctorFailure(this.message);
}
