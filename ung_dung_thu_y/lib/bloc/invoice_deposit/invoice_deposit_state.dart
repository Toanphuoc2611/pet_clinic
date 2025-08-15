import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_appoint.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_kennel.dart';

sealed class InvoiceDepositState {}

class InvoiceDepositInitial extends InvoiceDepositState {}

class InvoiceDepositGetStartedInProgress extends InvoiceDepositState {}

class InvoiceDepositGetStartedSuccess extends InvoiceDepositState {
  final List<InvoiceDepositDto> lists;
  InvoiceDepositGetStartedSuccess(this.lists);
}

class InvoiceDepositGetStartedFailure extends InvoiceDepositState {
  final String message;
  InvoiceDepositGetStartedFailure(this.message);
}

class InvoiceDepositPaymentInProgress extends InvoiceDepositState {}

class InvoiceDepositPaymentSuccess extends InvoiceDepositState {}

class InvoiceDepositPaymentFailure extends InvoiceDepositState {
  final String message;
  InvoiceDepositPaymentFailure(this.message);
}

class InvoiceDepositKennelSuccess extends InvoiceDepositState {
  final InvoiceDepositKennel invoiceDepositKennel;
  InvoiceDepositKennelSuccess(this.invoiceDepositKennel);
}

class InvoiceDepositAppointSuccess extends InvoiceDepositState {
  final InvoiceDepositAppoint invoiceDepositAppoint;
  InvoiceDepositAppointSuccess(this.invoiceDepositAppoint);
}
