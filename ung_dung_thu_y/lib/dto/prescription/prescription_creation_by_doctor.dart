import 'package:ung_dung_thu_y/dto/prescription/prescription_detail_req.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';

class PrescriptionCreationByDoctor {
  final String userId;
  final String petId;
  final List<ServicesGetDto> services;
  final String diagnose;
  final String note;
  final String reExamDate;
  final List<PrescriptionDetailReq> prescriptionDetail;

  PrescriptionCreationByDoctor({
    required this.userId,
    required this.petId,
    required this.services,
    required this.diagnose,
    required this.note,
    required this.reExamDate,
    required this.prescriptionDetail,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'petId': petId,
      'services': services.map((e) => e.toJson()).toList(),
      'diagnose': diagnose,
      'note': note,
      'reExamDate': reExamDate,
      'prescriptionDetail': prescriptionDetail.map((e) => e.toJson()).toList(),
    };
  }

  factory PrescriptionCreationByDoctor.fromJson(Map<String, dynamic> json) {
    return PrescriptionCreationByDoctor(
      userId: json['userId'],
      petId: json['petId'],
      services:
          (json['services'] as List<dynamic>)
              .map((e) => ServicesGetDto.fromJson(e))
              .toList(),
      diagnose: json['diagnose'],
      note: json['note'],
      reExamDate: json['reExamDate'],
      prescriptionDetail:
          (json['prescriptionDetail'] as List<dynamic>)
              .map((e) => PrescriptionDetailReq.fromJson(e))
              .toList(),
    );
  }
}
