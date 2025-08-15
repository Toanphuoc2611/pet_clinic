import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';

sealed class MedicalRecordState {}

class MedicalRecordInitial extends MedicalRecordState {}

class MedicalRecordGetInProgress extends MedicalRecordState {}

class MedicalRecordGetSuccess extends MedicalRecordState {
  final List<MedicalRecordDto> medicalRecords;
  MedicalRecordGetSuccess(this.medicalRecords);
}

class MedicalRecordGetFailure extends MedicalRecordState {
  final String message;
  MedicalRecordGetFailure(this.message);
}

class MedicalRecordGetByUserInProgress extends MedicalRecordState {}

class MedicalRecordGetByUserSuccess extends MedicalRecordState {
  final MedicalRecordDto medicalRecord;
  MedicalRecordGetByUserSuccess(this.medicalRecord);
}

class MedicalRecordGetByUserFailure extends MedicalRecordState {
  final String message;
  MedicalRecordGetByUserFailure(this.message);
}

class MedicalRecordGetByPetInProgress extends MedicalRecordState {}

class MedicalRecordGetByPetSuccess extends MedicalRecordState {
  final List<MedicalRecordDto> medicalRecords;
  MedicalRecordGetByPetSuccess(this.medicalRecords);
}

class MedicalRecordGetByPetFailure extends MedicalRecordState {
  final String message;
  MedicalRecordGetByPetFailure(this.message);
}
