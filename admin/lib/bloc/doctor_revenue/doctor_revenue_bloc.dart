import 'package:admin/bloc/doctor_revenue/doctor_revenue_event.dart';
import 'package:admin/bloc/doctor_revenue/doctor_revenue_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/user/user_get_dto.dart';
import 'package:admin/repository/invoice/invoice_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorRevenueBloc extends Bloc<DoctorRevenueEvent, DoctorRevenueState> {
  final InvoiceRepository invoiceRepository;
  final Map<String, UserGetDto> doctorMap = {};

  DoctorRevenueBloc(this.invoiceRepository) : super(DoctorRevenueInitial()) {
    on<DoctorRevenueGetStarted>(_onGetRevenueStarted);
    on<DoctorRevenueResetEvent>(_onReset);
  }

  void _onGetRevenueStarted(
    DoctorRevenueGetStarted event,
    Emitter<DoctorRevenueState> emit,
  ) async {
    emit(DoctorRevenueInProgress());

    try {
      final result = await invoiceRepository.getRevenueByDoctor(
        event.start,
        event.end,
        event.doctorId,
      );

      return (switch (result) {
        Success() => emit(
          DoctorRevenueSuccess(
            doctor: doctorMap[event.doctorId]!,
            revenue: result.data,
          ),
        ),
        Failure() => emit(DoctorRevenueFailure(result.message)),
      });
    } catch (e) {
      emit(DoctorRevenueFailure(e.toString()));
    }
  }

  void _onReset(
    DoctorRevenueResetEvent event,
    Emitter<DoctorRevenueState> emit,
  ) {
    emit(DoctorRevenueInitial());
  }

  void setDoctors(List<UserGetDto> doctors) {
    for (var doctor in doctors) {
      doctorMap[doctor.id] = doctor;
    }
  }
}
