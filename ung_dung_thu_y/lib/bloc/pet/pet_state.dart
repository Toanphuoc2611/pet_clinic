import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';

sealed class PetState {}

class PetAddInititial extends PetState {}

class PetAddInProgress extends PetState {}

class PetAddSuccess extends PetState {}

class PetAddFailure extends PetState {
  PetAddFailure(this.message);
  final String message;
}

class PetGetInProgress extends PetState {}

class PetGetSuccess extends PetState {
  final List<PetGetDto> list;
  PetGetSuccess(this.list);
}

class PetGetFailure extends PetState {
  PetGetFailure(this.message);
  final String message;
}

class PetDeleteInProgress extends PetState {}

class PetDeleteSuccess extends PetState {
  final bool isDeleted;
  PetDeleteSuccess(this.isDeleted);
}

class PetDeleteFailure extends PetState {
  PetDeleteFailure(this.message);
  final String message;
}

class PetUpdateInProgress extends PetState {}

class PetUpdateSuccess extends PetState {
  final PetGetDto petGetDto;
  PetUpdateSuccess(this.petGetDto);
}

class PetUpdateFailure extends PetState {
  PetUpdateFailure(this.message);
  final String message;
}

class PetGetByUserIdInProgress extends PetState {}

class PetGetByUserIdSuccess extends PetState {
  final List<PetGetDto> list;
  PetGetByUserIdSuccess(this.list);
}

class PetGetByUserIdFailure extends PetState {
  PetGetByUserIdFailure(this.message);
  final String message;
}

class PetGetKennelValidInProgress extends PetState {}

class PetGetKennelValidSuccess extends PetState {
  final List<PetGetDto> list;
  PetGetKennelValidSuccess(this.list);
}

class PetGetKennelValidFailure extends PetState {
  PetGetKennelValidFailure(this.message);
  final String message;
}
