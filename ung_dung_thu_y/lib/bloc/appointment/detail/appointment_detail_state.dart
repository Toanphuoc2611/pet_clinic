import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';

sealed class AppointmentDetailState {}

class AppointmentDetailGetInitial extends AppointmentDetailState {}

class AppointmentDetailGetInProgress extends AppointmentDetailState {}

class AppointmentDetailGetSuccess extends AppointmentDetailState {
  final AppointmentGetDto appointmentGetDto;
  AppointmentDetailGetSuccess(this.appointmentGetDto);
}

class AppointmentDetailGetFailure extends AppointmentDetailState {
  final String message;
  AppointmentDetailGetFailure(this.message);
}

class AppointmentDetailUpdateInProgress extends AppointmentDetailState {}

class AppointmentDetailUpdateSuccess extends AppointmentDetailState {
  final bool isSuccess;
  AppointmentDetailUpdateSuccess(this.isSuccess);
}

class AppointmentDetailUpdateFailure extends AppointmentDetailState {
  final String message;
  AppointmentDetailUpdateFailure(this.message);
}
