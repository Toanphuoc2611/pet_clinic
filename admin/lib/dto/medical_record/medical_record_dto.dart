import 'package:admin/dto/pet/pet_get_dto.dart';
import 'package:admin/dto/user/user_get_dto.dart';

class MedicalRecordDto {
  final int id;
  final PetGetDto pet;
  final UserGetDto user;
  final UserGetDto doctor;
  final String createdAt;
  final int status;

  MedicalRecordDto({
    required this.id,
    required this.pet,
    required this.user,
    required this.doctor,
    required this.createdAt,
    required this.status,
  });
  factory MedicalRecordDto.fromJson(Map<String, dynamic> json) {
    return MedicalRecordDto(
      id: json['id'],
      pet: PetGetDto.fromJson(json['pet']),
      user: UserGetDto.fromJson(json['pet']['user']),
      doctor: UserGetDto.fromJson(json['doctor']),
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }
}
