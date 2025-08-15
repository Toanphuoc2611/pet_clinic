import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_by_doctor.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_dto.dart';

class PrescriptionEvent {}

class PrescriptionCreated extends PrescriptionEvent {
  CreationPrescriptionReq req;
  PrescriptionCreated(this.req);
}

class PrescriptionCreatedByDoctor extends PrescriptionEvent {
  PrescriptionCreationByDoctor req;
  PrescriptionCreatedByDoctor(this.req);
}

class PrescriptionGetByPetStarted extends PrescriptionEvent {
  int medicalRecordId;
  PrescriptionGetByPetStarted(this.medicalRecordId);
}
