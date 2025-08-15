import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_dto.dart';

class PetEvent {}

class PetAddStarted extends PetEvent {
  final PetAddDto petAddDto;

  PetAddStarted(this.petAddDto);
}

class PetAddPrepare extends PetEvent {}

class PetGetStarted extends PetEvent {}

class PetDeleteStarted extends PetEvent {
  final String petId;
  PetDeleteStarted(this.petId);
}

class PetUpdateStarted extends PetEvent {
  final String petId;
  final PetUpdateDto petUpdateDto;

  PetUpdateStarted(this.petId, this.petUpdateDto);
}

class PetGetByUserIdStarted extends PetEvent {
  final String userId;
  PetGetByUserIdStarted(this.userId);
}

class PetGetKennelValidStarted extends PetEvent {}
