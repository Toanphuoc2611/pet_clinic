import 'package:bloc/bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository appointmentRepository;
  AppointmentBloc(this.appointmentRepository)
    : super(AppointmentGetInitital()) {
    on<AppointmentGetStarted>(_onGetAppointmentStarted);
    on<GetScheduleByDoctorStarted>(_onGetScheduleStarted);
    on<AppointmentCreationStarted>(_onCreateAppointmentStarted);
  }

  void _onGetAppointmentStarted(
    AppointmentGetStarted event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentGetInProgress());
    final result = await appointmentRepository.getAppointments(event.status);
    return (switch (result) {
      Success() => emit(AppointmentGetSuccess(result.data)),
      Failure() => emit(AppointmentFailure(result.message)),
    });
  }

  void _onGetScheduleStarted(
    GetScheduleByDoctorStarted event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(GeScheduleByDoctorInProgress());
    final result = await appointmentRepository.getScheduleByDoctor(
      event.doctorId,
    );

    return (switch (result) {
      Success() => emit(GetScheduleByDoctorSuccess(result.data)),
      Failure() => emit(AppointmentFailure(result.message)),
    });
  }

  void _onCreateAppointmentStarted(
    AppointmentCreationStarted event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentCreationInProgress());
    final result = await appointmentRepository.createAppointment(
      event.appointmentCreation,
    );

    return (switch (result) {
      Success() => emit(AppointmentCreationSuccess(result.data)),
      Failure() => emit(AppointmentFailure(result.message)),
    });
  }
}
