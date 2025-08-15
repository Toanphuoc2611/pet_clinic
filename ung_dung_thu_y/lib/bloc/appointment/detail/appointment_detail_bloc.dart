import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/detail/appointment_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/appointment/detail/appointment_detail_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';

class AppointmentDetailBloc
    extends Bloc<AppointmentDetailEvent, AppointmentDetailState> {
  final AppointmentRepository appointmentRepository;
  AppointmentDetailBloc(this.appointmentRepository)
    : super(AppointmentDetailGetInitial()) {
    on<AppointmentDetailGetStarted>(_onGetAppointment);
    on<AppointmentDetailUpdateStarted>(_onUpdateAppointment);
  }

  Future<void> _onGetAppointment(
    AppointmentDetailGetStarted event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    emit(AppointmentDetailGetInProgress());
    final result = await appointmentRepository.getAppointmentById(
      event.appointmentId,
    );
    return (switch (result) {
      Success() => emit(AppointmentDetailGetSuccess(result.data)),
      Failure() => emit(AppointmentDetailGetFailure(result.message)),
    });
  }

  Future<void> _onUpdateAppointment(
    AppointmentDetailUpdateStarted event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    emit(AppointmentDetailUpdateInProgress());
    final result = await appointmentRepository.updateAppointmentByUser(
      event.appointmentId,
    );
    return (switch (result) {
      Success() => emit(AppointmentDetailUpdateSuccess(result.data)),
      Failure() => emit(AppointmentDetailUpdateFailure(result.message)),
    });
  }
}
