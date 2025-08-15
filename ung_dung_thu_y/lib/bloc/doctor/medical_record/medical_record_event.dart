class MedicalRecordEvent {}

class MedicalRecordGetStarted extends MedicalRecordEvent {}

class MedicalRecordGetByUserStarted extends MedicalRecordEvent {
  final String petId;
  MedicalRecordGetByUserStarted(this.petId);
}

class MedicalRecordGetByPetStarted extends MedicalRecordEvent {
  final String petId;
  MedicalRecordGetByPetStarted(this.petId);
}
