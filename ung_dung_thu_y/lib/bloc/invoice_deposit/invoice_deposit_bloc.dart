import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/invoice_deposit/invoice_deposit_repository.dart';

class InvoiceDepositBloc
    extends Bloc<InvoiceDepositEvent, InvoiceDepositState> {
  final InvoiceDepositRepository invoiceDepositRepository;
  InvoiceDepositBloc(this.invoiceDepositRepository)
    : super(InvoiceDepositInitial()) {
    on<InvoiceDepositGetStarted>(_getStarted);
    on<InvoiceDepositPaymentStarted>(_payment);
    on<InvoiceDepositGetDetailStarted>(_getDetailStarted);
  }

  void _getStarted(
    InvoiceDepositGetStarted event,
    Emitter<InvoiceDepositState> emit,
  ) async {
    emit(InvoiceDepositGetStartedInProgress());
    final result = await invoiceDepositRepository.getInvoicesByUser();
    return (switch (result) {
      Success() => emit(InvoiceDepositGetStartedSuccess(result.data)),
      Failure() => emit(InvoiceDepositGetStartedFailure(result.message)),
    });
  }

  void _payment(
    InvoiceDepositPaymentStarted event,
    Emitter<InvoiceDepositState> emit,
  ) async {
    emit(InvoiceDepositPaymentInProgress());
    final result = await invoiceDepositRepository.paymentInvoice(
      event.invoiceId,
    );
    return (switch (result) {
      Success() => emit(InvoiceDepositPaymentSuccess()),
      Failure() => emit(InvoiceDepositPaymentFailure(result.message)),
    });
  }

  void _getDetailStarted(
    InvoiceDepositGetDetailStarted event,
    Emitter<InvoiceDepositState> emit,
  ) async {
    emit(InvoiceDepositGetStartedInProgress());
    if (event.type == 0) {
      final result = await invoiceDepositRepository.getInvoiceDepoKennel(
        event.idInvoice,
      );
      return (switch (result) {
        Success() => emit(InvoiceDepositKennelSuccess(result.data)),
        Failure() => emit(InvoiceDepositGetStartedFailure(result.message)),
      });
    } else if (event.type == 1) {
      final result = await invoiceDepositRepository.getInvoiceDepoAppoint(
        event.idInvoice,
      );
      return (switch (result) {
        Success() => emit(InvoiceDepositAppointSuccess(result.data)),
        Failure() => emit(InvoiceDepositGetStartedFailure(result.message)),
      });
    }
  }
}
