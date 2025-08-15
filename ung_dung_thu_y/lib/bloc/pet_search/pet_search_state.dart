import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';

sealed class PetSearchState {}

class PetSearchInitial extends PetSearchState {}

class PetSearchInProgress extends PetSearchState {}

class PetSearchSuccess extends PetSearchState {
  final List<PetGetDto> listPet;
  PetSearchSuccess(this.listPet);
}

class PetSearchFailure extends PetSearchState {
  final String message;
  PetSearchFailure(this.message);
}
