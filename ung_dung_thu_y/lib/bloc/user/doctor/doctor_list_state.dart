import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

sealed class DoctorListState {}

class DoctorListInitital extends DoctorListState {}

class DoctorListGetInProgress extends DoctorListState {}

class DoctorListGetSuccess extends DoctorListState {
  final List<UserGetDto> doctors;
  DoctorListGetSuccess(this.doctors);
}

class DoctorListGetFailure extends DoctorListState {
  final String message;
  DoctorListGetFailure(this.message);
}
