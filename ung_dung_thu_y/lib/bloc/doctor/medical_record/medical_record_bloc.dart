import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/medical_record/medical_record_repository.dart';

class MedicalRecordBloc extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  final MedicalRecordRepository medicalRecordRepository;
  MedicalRecordBloc(this.medicalRecordRepository)
    : super(MedicalRecordInitial()) {
    on<MedicalRecordGetStarted>(_onGetStarted);
    on<MedicalRecordGetByUserStarted>(_onGetByUserStarted);
    on<MedicalRecordGetByPetStarted>(_onGetByPetStarted);
  }

  void _onGetStarted(
    MedicalRecordGetStarted event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(MedicalRecordGetInProgress());
    final result = await medicalRecordRepository.getMedicalRecords();
    return (switch (result) {
      Success() => emit(MedicalRecordGetSuccess(result.data)),
      Failure() => emit(MedicalRecordGetFailure(result.message)),
    });
  }

  void _onGetByUserStarted(
    MedicalRecordGetByUserStarted event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(MedicalRecordGetInProgress());
    final result = await medicalRecordRepository.getMedicalRecordByUser(
      event.petId,
    );
    return (switch (result) {
      Success() => emit(MedicalRecordGetByUserSuccess(result.data)),
      Failure() => emit(MedicalRecordGetByUserFailure(result.message)),
    });
  }

  void _onGetByPetStarted(
    MedicalRecordGetByPetStarted event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(MedicalRecordGetInProgress());
    final result = await medicalRecordRepository.getListMedicalRecordByPet(
      event.petId,
    );
    return (switch (result) {
      Success() => emit(MedicalRecordGetByPetSuccess(result.data)),
      Failure() => emit(MedicalRecordGetByPetFailure(result.message)),
    });
  }
}
