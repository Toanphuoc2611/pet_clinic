import 'package:admin/dto/kennel/get_kennel_dto.dart';
import 'package:admin/dto/pet/pet_get_dto.dart';
import 'package:admin/dto/user/user_get_dto.dart';

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
    );
  }
}
