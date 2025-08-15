class InvoiceDepositEvent {}

class InvoiceDepositGetStarted extends InvoiceDepositEvent {}

class InvoiceDepositPaymentStarted extends InvoiceDepositEvent {
  final int invoiceId;
  InvoiceDepositPaymentStarted(this.invoiceId);
}

class InvoiceDepositGetDetailStarted extends InvoiceDepositEvent {
  final int idInvoice;
  final int type;
  InvoiceDepositGetDetailStarted({required this.idInvoice, required this.type});
}
