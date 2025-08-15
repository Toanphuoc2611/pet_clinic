import 'package:bloc/bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/prescription/prescription_repository.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final PrescriptionRepository prescriptionRepository;
  PrescriptionBloc(this.prescriptionRepository) : super(PrescriptionInitial()) {
    on<PrescriptionCreated>(_onCreationStarted);
    on<PrescriptionGetByPetStarted>(_onGetByPetStarted);
    on<PrescriptionCreatedByDoctor>(_onCreationByDoctorStarted);
  }

  void _onCreationStarted(PrescriptionCreated event, Emitter emit) async {
    emit(PrescriptionCreatedInProgress());
    final result = await prescriptionRepository.createPrescription(event.req);
    return (switch (result) {
      Success() => emit(PrescriptionCreatedSuccess(result.data)),
      Failure() => emit(PrescriptionCreatedFailure(result.message)),
    });
  }

  void _onCreationByDoctorStarted(
    PrescriptionCreatedByDoctor event,
    Emitter emit,
  ) async {
    emit(PrescriptionCreatedByDoctorInProgress());
    final result = await prescriptionRepository.createPrescriptionByDoctor(
      event.req,
    );
    return (switch (result) {
      Success() => emit(PrescriptionCreatedByDoctorSuccess(result.data)),
      Failure() => emit(PrescriptionCreatedByDoctorFailure(result.message)),
    });
  }

  void _onGetByPetStarted(
    PrescriptionGetByPetStarted event,
    Emitter emit,
  ) async {
    emit(PrescriptionGetByPetInProgress());
    final result = await prescriptionRepository.getPrescriptionsByPetId(
      event.medicalRecordId,
    );
    return (switch (result) {
      Success() => emit(PrescriptionGetByPetSuccess(result.data)),
      Failure() => emit(PrescriptionGetByPetFailure(result.message)),
    });
  }
}
