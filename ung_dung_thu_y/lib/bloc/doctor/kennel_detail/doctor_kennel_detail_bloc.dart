import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';

class DoctorKennelDetailBloc
    extends Bloc<DoctocKennelDetailEvent, DoctorKennelDetailState> {
  final KennelDetailRepository kennelDetailRepository;
  DoctorKennelDetailBloc(this.kennelDetailRepository)
    : super(DoctorKennelDetailInitial()) {
    on<DoctorKennelDetailGetStarted>(_onGetStarted);
    on<DoctorKennelDetailGetByPetStarted>(_onGetByPetStarted);
    on<DoctorKennelDetailUpdateStatusStarted>(_onUpdateStatusStarted);
    on<DoctorKennelDetailCompleteBooking>(_onCompleteBookingStarted);
  }

  void _onGetStarted(DoctorKennelDetailGetStarted event, Emitter emit) async {
    emit(DoctorKennelDetailStartedInProgress());
    var result = await kennelDetailRepository.getKennelOfDoctorToday();
    return (switch (result) {
      Success() => emit(DoctorKennelDetailGetSuccess(result.data)),
      Failure() => emit(DoctorKennelDetailGetFailure(result.message)),
    });
  }

  void _onGetByPetStarted(
    DoctorKennelDetailGetByPetStarted event,
    Emitter emit,
  ) async {
    emit(DoctorKennelDetailGetByPetStartedInProgress());
    var result = await kennelDetailRepository.getKennelsByPetId(event.petId);
    return (switch (result) {
      Success() => emit(DoctorKennelDetailGetByPetSuccess(result.data)),
      Failure() => emit(DoctorKennelDetailGetByPetFailure(result.message)),
    });
  }

  void _onUpdateStatusStarted(
    DoctorKennelDetailUpdateStatusStarted event,
    Emitter emit,
  ) async {
    emit(DoctorKennelDetailUpdateStartedInProgress());
    final result = await kennelDetailRepository.updateKennelStatus(
      event.kennelId,
      event.status,
    );
    return (switch (result) {
      Success() => emit(DoctorKennelDetailUpdateSuccess(result.data)),
      Failure() => emit(DoctorKennelDetailUpdateFailure(result.message)),
    });
  }

  void _onCompleteBookingStarted(
    DoctorKennelDetailCompleteBooking event,
    Emitter emit,
  ) async {
    emit(DoctorKennelDetailCompleteBookingInProgress());
    final result = await kennelDetailRepository.completeKennelBooking(event.id);
    return (switch (result) {
      Success() => emit(DoctorKennelDetailCompleteBookingSuccess(result.data)),
      Failure() => emit(
        DoctorKennelDetailCompleteBookingFailure(result.message),
      ),
    });
  }
}
