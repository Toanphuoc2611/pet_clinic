import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class KennelDetailDto {
  final int id;
  final String? inTime;
  final String? outTime;
  final int status;
  final PetGetDto pet;
  final UserGetDto doctor;
  final String? createdAt;
  final String? note;
  final KennelDto kennel;
  final String? actualCheckout;
  final String? actualCheckin;
  final InvoiceDepositDto invoiceDepositDto;

  KennelDetailDto({
    required this.id,
    this.inTime,
    this.outTime,
    required this.status,
    required this.pet,
    required this.doctor,
    this.createdAt,
    this.note,
    required this.kennel,
    this.actualCheckout,
    this.actualCheckin,
    required this.invoiceDepositDto,
  });

  factory KennelDetailDto.fromJson(Map<String, dynamic> json) {
    return KennelDetailDto(
      id: json['id'],
      inTime: json['inTime'],
      outTime: json['outTime'],
      status: json['status'],
      pet: PetGetDto.fromJson(json['pet']),
      doctor: UserGetDto.fromJson(json['doctor']),
      createdAt: json['createdAt'],
      note: json['note'],
      kennel: KennelDto.fromJson(json['kennel']),
      actualCheckin: json['actualCheckin'],
      actualCheckout: json['actualCheckout'],
      invoiceDepositDto: InvoiceDepositDto.fromJson(json['invoiceDeposit']),
    );
  }
}
