import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_state.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';

class DoctorAppointmentBloc
    extends Bloc<DoctorAppointmentEvent, DoctorAppointmentState> {
  final AppointmentRepository appointmentRepository;
  DoctorAppointmentBloc(this.appointmentRepository)
    : super(DoctorAppointmentInitial()) {
    on<DoctorAppointmentGetStarted>(_onGetStarted);
  }

  void _onGetStarted(
    DoctorAppointmentGetStarted event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    emit(DoctorAppointmentGetTodayInProgress());
    var result = await appointmentRepository.getAppointmentOfDoctorByDate(
      event.date,
    );
    return (switch (result) {
      Success() => emit(DoctorAppointmentGetTodaySuccess(result.data)),
      Failure() => emit(
        DoctorAppointmentGetTodayFailure(message: result.message),
      ),
    });
  }
}
