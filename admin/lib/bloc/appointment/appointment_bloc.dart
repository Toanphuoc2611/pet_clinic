import 'package:admin/bloc/appointment/appointment_event.dart';
import 'package:admin/bloc/appointment/appointment_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/appointment/appointment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository appointmentRepository;

  AppointmentBloc(this.appointmentRepository) : super(AppointmentInitial()) {
    on<AppointmentGetWeeklyStarted>(_onGetWeeklyStarted);
  }

  void _onGetWeeklyStarted(
    AppointmentGetWeeklyStarted event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentGetInProgress());
    var result = await appointmentRepository.getAllDoctorsAppointmentsInWeek(
      event.startDate,
    );
    return (switch (result) {
      Success() => emit(
        AppointmentGetWeeklySuccess(result.data, event.startDate),
      ),
      Failure() => emit(AppointmentGetFailure(result.message)),
    });
  }
}
