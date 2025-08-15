import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class InvoiceKennelDto {
  final int id;
  final String invoiceCode;
  final int status;
  final int totalAmount;
  final int deposit;
  final String createdAt;
  final UserGetDto doctor;
  final UserGetDto user;
  final KennelDetailDto kennelDetail;

  InvoiceKennelDto({
    required this.id,
    required this.invoiceCode,
    required this.status,
    required this.totalAmount,
    required this.deposit,
    required this.createdAt,
    required this.doctor,
    required this.user,
    required this.kennelDetail,
  });

  factory InvoiceKennelDto.fromJson(Map<String, dynamic> json) {
    return InvoiceKennelDto(
      id: json['id'] ?? 0,
      invoiceCode: json['invoiceCode'] ?? '',
      status: json['status'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      deposit: json['deposit'] ?? 0,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      doctor: UserGetDto.fromJson(json['doctor'] ?? {}),
      user: UserGetDto.fromJson(json['user'] ?? {}),
      kennelDetail: KennelDetailDto.fromJson(json['kennelDetail'] ?? {}),
    );
  }
}
