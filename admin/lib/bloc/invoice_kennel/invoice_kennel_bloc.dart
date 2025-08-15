import 'package:admin/bloc/invoice_kennel/invoice_kennel_event.dart';
import 'package:admin/bloc/invoice_kennel/invoice_kennel_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/invoice_kennel/invoice_kennel_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceKennelBloc extends Bloc<InvoiceKennelEvent, InvoiceKennelState> {
  final InvoiceKennelRepository invoiceKennelRepository;
  InvoiceKennelBloc(this.invoiceKennelRepository)
    : super(InvoiceKennelInitial()) {
    on<InvoiceKennelGetRevenueStarted>(_onGetRevenueStarted);
    on<InvoiceKennelGetRevenueByDoctorStarted>(_onGetRevenueByDoctorStarted);
  }

  void _onGetRevenueStarted(
    InvoiceKennelGetRevenueStarted event,
    Emitter<InvoiceKennelState> emit,
  ) async {
    emit(InvoiceKennelGetRevenueInProgress());
    final result = await invoiceKennelRepository.getRevenue(
      event.start,
      event.end,
    );
    return (switch (result) {
      Success() => emit(InvoiceKennelGetRevenueSuccess(result.data)),
      Failure() => emit(InvoiceKennelGetRevenueFailure(result.message)),
    });
  }

  void _onGetRevenueByDoctorStarted(
    InvoiceKennelGetRevenueByDoctorStarted event,
    Emitter<InvoiceKennelState> emit,
  ) async {
    emit(InvoiceKennelGetRevenueInProgress());
    final result = await invoiceKennelRepository.getRevenueByDoctor(
      event.start,
      event.end,
      event.doctorId,
    );
    return (switch (result) {
      Success() => emit(InvoiceKennelGetRevenueSuccess(result.data)),
      Failure() => emit(InvoiceKennelGetRevenueFailure(result.message)),
    });
  }
}
