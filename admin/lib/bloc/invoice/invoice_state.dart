sealed class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceGetRevenueInProgress extends InvoiceState {}

class InvoiceGetRevenueSuccess extends InvoiceState {
  final int revenue;
  InvoiceGetRevenueSuccess(this.revenue);
}

class InvoiceGetRevenueFailure extends InvoiceState {
  final String message;
  InvoiceGetRevenueFailure(this.message);
}

class InvoiceGetRevenueByDoctorInProgress extends InvoiceState {}

class InvoiceGetRevenueByDoctorSuccess extends InvoiceState {
  final int revenue;
  InvoiceGetRevenueByDoctorSuccess(this.revenue);
}

class InvoiceGetRevenueByDoctorFailure extends InvoiceState {
  final String message;
  InvoiceGetRevenueByDoctorFailure(this.message);
}
