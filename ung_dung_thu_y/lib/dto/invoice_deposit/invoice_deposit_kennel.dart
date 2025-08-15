import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class InvoiceDepositKennel {
  final int idInvoiceDepo;
  final String invoiceCode;
  final String createdAt;
  final int totalAmount;
  final String inTime;
  final String outTime;
  final int priceService;
  final int status;
  final int deposit;
  final KennelDto kennel;
  final UserGetDto user;
  final PetGetDto pet;

  InvoiceDepositKennel({
    required this.idInvoiceDepo,
    required this.invoiceCode,
    required this.createdAt,
    required this.totalAmount,
    required this.inTime,
    required this.outTime,
    required this.priceService,
    required this.status,
    required this.deposit,
    required this.kennel,
    required this.user,
    required this.pet,
  });

  factory InvoiceDepositKennel.fromJson(Map<String, dynamic> json) {
    return InvoiceDepositKennel(
      idInvoiceDepo: json['idInvoiceDepo'],
      invoiceCode: json['invoiceCode'],
      createdAt: json['createdAt'],
      totalAmount: json['totalAmount'],
      inTime: json['inTime'],
      outTime: json['outTime'],
      priceService: json['priceService'],
      status: json['status'],
      deposit: json['deposit'],
      kennel: KennelDto.fromJson(json['kennel']),
      user: UserGetDto.fromJson(json['user']),
      pet: PetGetDto.fromJson(json['pet']),
    );
  }
}
