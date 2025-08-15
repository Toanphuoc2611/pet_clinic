import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_event.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final UserRepository userRepository;
  DoctorListBloc(this.userRepository) : super(DoctorListInitital()) {
    on<DoctorListGetStarted>(_onGetListDoctorStarted);
  }

  void _onGetListDoctorStarted(
    DoctorListGetStarted event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(DoctorListGetInProgress());
    final result = await userRepository.getListDoctors();
    return (switch (result) {
      Success() => emit(DoctorListGetSuccess(result.data)),
      Failure() => emit(DoctorListGetFailure(result.message)),
    });
  }
}
