import 'package:admin/bloc/invoice/invoice_event.dart';
import 'package:admin/bloc/invoice/invoice_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/invoice/invoice_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository invoiceRepository;
  InvoiceBloc(this.invoiceRepository) : super(InvoiceInitial()) {
    on<InvoiceGetRevenueStarted>(_onGetRevenueStarted);
    on<InvoiceGetRevenueByDoctorStarted>(_onGetRevenueByDoctorStarted);
  }

  void _onGetRevenueStarted(
    InvoiceGetRevenueStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceGetRevenueInProgress());
    final result = await invoiceRepository.getRevenue(event.start, event.end);
    return (switch (result) {
      Success() => emit(InvoiceGetRevenueSuccess(result.data)),
      Failure() => emit(InvoiceGetRevenueFailure(result.message)),
    });
  }

  void _onGetRevenueByDoctorStarted(
    InvoiceGetRevenueByDoctorStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceGetRevenueInProgress());
    final result = await invoiceRepository.getRevenueByDoctor(
      event.start,
      event.end,
      event.doctorId,
    );
    return (switch (result) {
      Success() => emit(InvoiceGetRevenueSuccess(result.data)),
      Failure() => emit(InvoiceGetRevenueFailure(result.message)),
    });
  }
}
