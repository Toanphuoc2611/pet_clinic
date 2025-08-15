class DoctocKennelDetailEvent {}

class DoctorKennelDetailGetStarted extends DoctocKennelDetailEvent {}

class DoctorKennelDetailGetByPetStarted extends DoctocKennelDetailEvent {
  final String petId;
  DoctorKennelDetailGetByPetStarted(this.petId);
}

class DoctorKennelDetailUpdateStatusStarted extends DoctocKennelDetailEvent {
  final String kennelId;
  final String status;
  DoctorKennelDetailUpdateStatusStarted(this.kennelId, this.status);
}

class DoctorKennelDetailCompleteBooking extends DoctocKennelDetailEvent {
  final String id;
  DoctorKennelDetailCompleteBooking(this.id);
}
