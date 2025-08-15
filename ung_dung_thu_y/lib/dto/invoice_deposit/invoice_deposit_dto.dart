import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class InvoiceDepositDto {
  int id;
  String invoiceCode;
  UserGetDto user;
  String createdAt;
  int status;
  int totalAmount;
  int deposit;
  int type;

  InvoiceDepositDto({
    required this.id,
    required this.user,
    required this.invoiceCode,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.deposit,
    required this.type,
  });

  factory InvoiceDepositDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDepositDto(
      id: json['id'],
      invoiceCode: json['invoiceCode'],
      user: UserGetDto.fromJson(json['user']),
      createdAt: json['createdAt'],
      status: json['status'],
      totalAmount: json['totalAmount'],
      deposit: json['deposit'],
      type: json['type'],
    );
  }
}
