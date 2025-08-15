import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_event.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/invoice/invoice_repository.dart';

class RedirectVnpayBloc extends Bloc<RedirectVnPayEvent, RedirectVnpayState> {
  final InvoiceRepository invoiceRepository;
  RedirectVnpayBloc(this.invoiceRepository) : super(RedirectVnpayInitial()) {
    on<RedirectVnpayStarted>(_onRedirectStarted);
  }

  void _onRedirectStarted(
    RedirectVnpayStarted event,
    Emitter<RedirectVnpayState> emit,
  ) async {
    emit(RedirectVnpayInProgress());
    final result = await invoiceRepository.redirectPaymentVnpay(
      event.vnPayRequestDto,
    );
    return (switch (result) {
      Success() => emit(RedirectVnpaySuccess(result.data)),
      Failure() => emit(RedirectVnpayFailure(result.message)),
    });
  }
}
