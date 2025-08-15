import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class InvoiceDepositAppoint {
  final int idInvoiceDepo;
  final String invoiceCode;
  final String createdAt;
  final int totalAmount;
  final String appointmentTime;
  final List<ServicesGetDto> services;
  final int status;
  final int deposit;
  final UserGetDto user;
  InvoiceDepositAppoint({
    required this.idInvoiceDepo,
    required this.invoiceCode,
    required this.createdAt,
    required this.totalAmount,
    required this.appointmentTime,
    required this.services,
    required this.status,
    required this.deposit,
    required this.user,
  });

  factory InvoiceDepositAppoint.fromJson(Map<String, dynamic> json) {
    return InvoiceDepositAppoint(
      idInvoiceDepo: json['idInvoiceDepo'] as int,
      invoiceCode: json['invoiceCode'] as String,
      createdAt: json['createdAt'] as String,
      totalAmount: json['totalAmount'] as int,
      appointmentTime: json['appointmentTime'] as String,
      services:
          (json['services'] as List<dynamic>)
              .map(
                (service) =>
                    ServicesGetDto.fromJson(service as Map<String, dynamic>),
              )
              .toList(),
      status: json['status'] as int,
      deposit: json['deposit'] as int,
      user: UserGetDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
