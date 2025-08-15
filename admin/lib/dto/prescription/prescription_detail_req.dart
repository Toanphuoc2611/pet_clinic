import 'package:admin/dto/medication/medication_dto.dart';

class PrescriptionDetailReq {
  final String dosage;
  final int quantity;
  final MedicationDto medication;

  PrescriptionDetailReq({
    required this.dosage,
    required this.quantity,
    required this.medication,
  });
  factory PrescriptionDetailReq.fromJson(Map<String, dynamic> json) {
    return PrescriptionDetailReq(
      dosage: json['dosage'],
      quantity: json['quantity'],
      medication: MedicationDto.fromJson(json['medication']),
    );
  }
  Map<String, dynamic> toJson() => {
    'dosage': dosage,
    'quantity': quantity,
    'medication': medication.toJson(),
  };
}
