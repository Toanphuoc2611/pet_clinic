import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class InvoiceDto {
  final int id;
  final String invoiceCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalAmount;
  final PetGetDto pet;
  final UserGetDto user;
  final UserGetDto doctor;
  final int status;

  InvoiceDto({
    required this.id,
    required this.invoiceCode,
    required this.createdAt,
    required this.updatedAt,
    required this.totalAmount,
    required this.pet,
    required this.user,
    required this.doctor,
    required this.status,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDto(
      id: json['id'] ?? 0,
      invoiceCode: json['invoiceCode'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      totalAmount: json['totalAmount'] ?? 0,
      pet: PetGetDto.fromJson(json['pet'] ?? {}),
      user: UserGetDto.fromJson(json['user'] ?? {}),
      doctor: UserGetDto.fromJson(json['doctor'] ?? {}),
      status: json['status'] ?? 0,
    );
  }
}
