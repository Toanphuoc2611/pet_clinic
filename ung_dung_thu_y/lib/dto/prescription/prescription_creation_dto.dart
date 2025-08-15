import 'package:ung_dung_thu_y/dto/prescription/prescription_detail_req.dart';

class CreationPrescriptionReq {
  final String diagnose;
  final String note;
  final String? reExamDate;
  final String petId;
  final int idAppointment;
  final List<PrescriptionDetailReq>? prescriptionDetail;

  CreationPrescriptionReq({
    required this.diagnose,
    required this.note,
    this.reExamDate,
    required this.petId,
    required this.idAppointment,
    this.prescriptionDetail,
  });

  Map<String, dynamic> toJson() => {
    'diagnose': diagnose,
    'note': note,
    'reExamDate': reExamDate,
    'petId': petId,
    'idAppointment': idAppointment,
    'prescriptionDetail': prescriptionDetail?.map((e) => e.toJson()).toList(),
  };
}
