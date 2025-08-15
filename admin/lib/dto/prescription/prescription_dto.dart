import 'package:admin/dto/prescription/prescription_detail_req.dart';
import 'package:admin/dto/user/user_get_dto.dart';

class PrescriptionDto {
  final int id;
  final UserGetDto doctor;
  final String diagnose;
  final String? reExamDate;
  final String createdAt;
  final String note;
  final List<PrescriptionDetailReq> prescriptionDetails;

  PrescriptionDto({
    required this.id,
    required this.doctor,
    required this.diagnose,
    this.reExamDate,
    required this.createdAt,
    required this.note,
    this.prescriptionDetails = const [],
  });

  factory PrescriptionDto.fromJson(Map<String, dynamic> json) {
    return PrescriptionDto(
      id: json['id'],
      doctor: UserGetDto.fromJson(json['doctor']),
      diagnose: json['diagnose'],
      reExamDate: json['reExamDate'],
      createdAt: json['createdAt'],
      note: json['note'],
      prescriptionDetails:
          json['prescriptionDetail'] != null
              ? (json['prescriptionDetail'] as List<dynamic>)
                  .map((e) => PrescriptionDetailReq.fromJson(e))
                  .toList()
              : [],
    );
  }
}
