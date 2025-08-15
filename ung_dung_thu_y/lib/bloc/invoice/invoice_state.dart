import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';

sealed class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class PaymentInvoiceInProgress extends InvoiceState {}

class PaymentInvoiceSuccess extends InvoiceState {}

class PaymentInvoiceFailure extends InvoiceState {
  final String message;
  PaymentInvoiceFailure(this.message);
}

class PaymentInvoiceKennelSuccess extends InvoiceState {}

class PaymentInvoiceKennelFailure extends InvoiceState {
  final String message;
  PaymentInvoiceKennelFailure(this.message);
}

class InvoiceGetAllInProgress extends InvoiceState {}

class InvoiceGetAllSuccess extends InvoiceState {
  final List<InvoiceDto> invoices;
  final List<InvoiceKennelDto> invoiceKennels;
  InvoiceGetAllSuccess(this.invoices, this.invoiceKennels);
}

class InvoiceGetAllFailure extends InvoiceState {
  final String message;
  InvoiceGetAllFailure(this.message);
}

class InvoiceGetInProgress extends InvoiceState {}

class InvoiceGetSuccess extends InvoiceState {
  final List<InvoiceDto> invoices;
  InvoiceGetSuccess(this.invoices);
}

class InvoiceGetFailure extends InvoiceState {
  final String message;
  InvoiceGetFailure(this.message);
}

class InvoiceKennelGetInProgress extends InvoiceState {}

class InvoiceKennelGetSuccess extends InvoiceState {
  final List<InvoiceKennelDto> invoiceKennels;
  InvoiceKennelGetSuccess(this.invoiceKennels);
}

class InvoiceKennelGetFailure extends InvoiceState {
  final String message;
  InvoiceKennelGetFailure(this.message);
}

class InvoiceGetByUserInProgress extends InvoiceState {}

class InvoiceGetByUserSuccess extends InvoiceState {
  final List<InvoiceResponse> invoices;
  InvoiceGetByUserSuccess(this.invoices);
}

class InvoiceGetByUserFailure extends InvoiceState {
  final String message;
  InvoiceGetByUserFailure(this.message);
}

class InvoiceKennelGetByUserInProgress extends InvoiceState {}

class InvoiceKennelGetByUserSuccess extends InvoiceState {
  final List<InvoiceKennelDto> invoiceKennels;
  InvoiceKennelGetByUserSuccess(this.invoiceKennels);
}

class InvoiceKennelGetByUserFailure extends InvoiceState {
  final String message;
  InvoiceKennelGetByUserFailure(this.message);
}
