import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_state.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/invoice/invoice_repository.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository invoiceRepository;
  InvoiceBloc(this.invoiceRepository) : super(InvoiceInitial()) {
    on<PaymentInvoiceStarted>(_onPaymentInvoiceStarted);
    on<PaymentInvoiceKennel>(_onPaymentInvoiceKennel);
    on<InvoiceGetStarted>(_onGetInvoices);
    on<InvoiceKennelGetStarted>(_onGetKennelInvoices);
    on<InvoiceGetByUserStarted>(_onGetInvoicesByUser);
    on<InvoiceKennelGetByUserStarted>(_onGetKennelInvoicesByUser);
  }

  void _onPaymentInvoiceStarted(
    PaymentInvoiceStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(PaymentInvoiceInProgress());
    final result = await invoiceRepository.paymentInvoice(event.invoiceId);
    return (switch (result) {
      Success() => emit(PaymentInvoiceSuccess()),
      Failure() => emit(PaymentInvoiceFailure(result.message)),
    });
  }

  void _onPaymentInvoiceKennel(
    PaymentInvoiceKennel event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(PaymentInvoiceInProgress());
    final result = await invoiceRepository.paymentInvoiceKennel(
      event.invoiceId,
    );
    return (switch (result) {
      Success() => emit(PaymentInvoiceKennelSuccess()),
      Failure() => emit(PaymentInvoiceKennelFailure(result.message)),
    });
  }

  void _onGetInvoices(
    InvoiceGetStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceGetInProgress());

    final result = await invoiceRepository.getInvoicesByDocter();

    if (result is Failure<List<InvoiceDto>>) {
      emit(InvoiceGetFailure(result.message));
      return;
    }

    final invoices = (result as Success<List<InvoiceDto>>).data;
    emit(InvoiceGetSuccess(invoices));
  }

  void _onGetKennelInvoices(
    InvoiceKennelGetStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceKennelGetInProgress());
    final result = await invoiceRepository.getInvoicesKennelsByDocter();

    return (switch (result) {
      Success() => emit(InvoiceKennelGetSuccess((result).data)),
      Failure() => emit(InvoiceKennelGetFailure((result).message)),
    });
  }

  void _onGetInvoicesByUser(
    InvoiceGetByUserStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceGetByUserInProgress());

    final result = await invoiceRepository.getInvoicesByUser();

    if (result is Failure<List<InvoiceResponse>>) {
      emit(InvoiceGetByUserFailure(result.message));
      return;
    }

    final invoices = (result as Success<List<InvoiceResponse>>).data;
    emit(InvoiceGetByUserSuccess(invoices));
  }

  void _onGetKennelInvoicesByUser(
    InvoiceKennelGetByUserStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceKennelGetByUserInProgress());
    final result = await invoiceRepository.getInvoicesKennelsByUser();

    return (switch (result) {
      Success() => emit(InvoiceKennelGetByUserSuccess((result).data)),
      Failure() => emit(InvoiceKennelGetByUserFailure((result).message)),
    });
  }
}
