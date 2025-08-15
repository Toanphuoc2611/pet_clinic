import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class PetGetDto {
  final String id;
  final String name;
  final String? birthday;
  final String? type;
  final String? breed;
  final String? color;
  final int gender; // 0: male, 1: female
  final double weight;
  final int isNeutered; // 0: false, 1: true
  final String? note;
  String? avatar;
  final String updateAt;
  final UserGetDto? owner;

  PetGetDto({
    required this.id,
    required this.name,
    this.birthday,
    this.type,
    this.breed,
    this.color,
    this.gender = 0,
    this.weight = 0.0,
    this.isNeutered = 0,
    this.note,
    this.avatar,
    required this.updateAt,
    this.owner,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'type': type,
      'breed': breed,
      'color': color,
      'gender': gender,
      'weight': weight,
      'is_neutered': isNeutered,
      'note': note,
      'updatedAt': updateAt,
      'userId': owner?.id,
    };
  }

  factory PetGetDto.fromJson(Map<String, dynamic> json) {
    return PetGetDto(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'],
      type: json['type'],
      breed: json['breed'],
      color: json['color'],
      gender: json['gender'],
      weight: json['weight'],
      isNeutered: json['isNeutered'],
      note: json['note'],
      avatar: json['avatar'],
      updateAt: json['updatedAt'],
      owner: json['user'] != null ? UserGetDto.fromJson(json['user']) : null,
    );
  }
}
