abstract class MedicalRecordManagementEvent {}

class LoadMedicalRecordsEvent extends MedicalRecordManagementEvent {}

class SearchMedicalRecordsEvent extends MedicalRecordManagementEvent {
  final String query;
  SearchMedicalRecordsEvent(this.query);
}

class FilterMedicalRecordsByStatusEvent extends MedicalRecordManagementEvent {
  final int? status;
  FilterMedicalRecordsByStatusEvent(this.status);
}

class ChangePaginationEvent extends MedicalRecordManagementEvent {
  final int page;
  ChangePaginationEvent(this.page);
}

class LoadPrescriptionDetailsEvent extends MedicalRecordManagementEvent {
  final int medicalRecordId;
  LoadPrescriptionDetailsEvent(this.medicalRecordId);
}
