import 'package:admin/dto/prescription/prescription_detail_req.dart';
import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/dto/user/user_get_dto.dart';

class InvoiceResponse {
  final int id;
  final String invoiceCode;
  final int totalAmount;
  final UserGetDto user;
  final UserGetDto doctor;
  final int status;
  final List<ServicesGetDto> services;
  final List<PrescriptionDetailReq> prescriptionDetail;
  final String createdAt;

  InvoiceResponse({
    required this.id,
    required this.invoiceCode,
    required this.totalAmount,
    required this.user,
    required this.doctor,
    required this.status,
    required this.services,
    required this.prescriptionDetail,
    required this.createdAt,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      id: json['id'],
      invoiceCode: json['invoiceCode'],
      totalAmount: json['totalAmount'],
      user: UserGetDto.fromJson(json['user']),
      doctor: UserGetDto.fromJson(json['doctor']),
      status: json['status'],
      services:
          (json['services'] as List<dynamic>)
              .map((e) => ServicesGetDto.fromJson(e))
              .toList(),
      prescriptionDetail:
          (json['prescriptionDetail'] as List<dynamic>)
              .map((e) => PrescriptionDetailReq.fromJson(e))
              .toList(),
      createdAt: json['createdAt'],
    );
  }
}
