import 'package:ung_dung_thu_y/dto/user/user_creation_request.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

class UserEvent {}

class UserGetStarted extends UserEvent {}

class UserUpdatePrepare extends UserEvent {
  final UserGetDto user;
  UserUpdatePrepare({required this.user});
}

class UserUpdateStarted extends UserEvent {
  UserUpdateStarted({
    required this.id,
    this.fullname,
    this.birthday,
    this.gender,
    this.address,
  });
  final String id;
  final String? fullname;
  final String? birthday;
  final int? gender;
  final String? address;
}

class UserSearchStarted extends UserEvent {
  final String query;
  UserSearchStarted(this.query);
}

class UserSearchCleared extends UserEvent {}

class UserCreateStarted extends UserEvent {
  final UserCreationRequest userCreationRequest;
  UserCreateStarted({required this.userCreationRequest});
}
