class UpdateMedicationStatus {
  final int medicationId;
  final int isSale;

  UpdateMedicationStatus({required this.medicationId, required this.isSale});

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'isSale': isSale,
  };
}
