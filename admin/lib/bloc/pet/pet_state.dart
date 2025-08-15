import 'package:admin/dto/pet/pet_get_dto.dart';

abstract class PetState {}

class PetInitial extends PetState {}

class PetGetInProgress extends PetState {}

class PetGetByUserIdSuccess extends PetState {
  final List<PetGetDto> petList;
  PetGetByUserIdSuccess(this.petList);
}

class PetGetFailure extends PetState {
  final String message;
  PetGetFailure(this.message);
}
