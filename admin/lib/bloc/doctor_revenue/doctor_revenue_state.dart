import 'package:admin/dto/user/user_get_dto.dart';

sealed class DoctorRevenueState {}

class DoctorRevenueInitial extends DoctorRevenueState {}

class DoctorRevenueInProgress extends DoctorRevenueState {}

class DoctorRevenueSuccess extends DoctorRevenueState {
  final UserGetDto doctor;
  final int revenue;

  DoctorRevenueSuccess({required this.doctor, required this.revenue});
}

class DoctorRevenueFailure extends DoctorRevenueState {
  final String message;

  DoctorRevenueFailure(this.message);
}
