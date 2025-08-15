class InvoiceEvent {}

class PaymentInvoiceStarted extends InvoiceEvent {
  final int invoiceId;
  PaymentInvoiceStarted(this.invoiceId);
}

class PaymentInvoiceKennel extends InvoiceEvent {
  final int invoiceId;
  PaymentInvoiceKennel(this.invoiceId);
}

class InvoiceGetStarted extends InvoiceEvent {}

class InvoiceKennelGetStarted extends InvoiceEvent {}

class InvoiceGetByUserStarted extends InvoiceEvent {}

class InvoiceKennelGetByUserStarted extends InvoiceEvent {}
