import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';

sealed class UserState {}

class UserInitial extends UserState {}

class UserGetInProgress extends UserState {}

class UserGetSuccess extends UserState {
  final UserGetDto userGetDto;
  UserGetSuccess(this.userGetDto);
}

class UserGetFailure extends UserState {
  UserGetFailure(this.message);
  final String message;
}

class UserUpdateInitial extends UserState {
  final UserGetDto userGetDto;
  UserUpdateInitial(this.userGetDto);
}

class UserUpdateInProgress extends UserState {}

class UserUpdateSuccess extends UserState {}

class UserUpdateFailure extends UserState {
  UserUpdateFailure(this.message);
  final String message;
}

class UserSearchInProgress extends UserState {}

class UserSearchSuccess extends UserState {
  final List<UserGetDto> users;
  UserSearchSuccess(this.users);
}

class UserSearchFailure extends UserState {
  final String message;
  UserSearchFailure(this.message);
}

class UserCreateInProgress extends UserState {}

class UserCreateSuccess extends UserState {
  final UserGetDto user;
  UserCreateSuccess(this.user);
}

class UserCreateFailure extends UserState {
  final String message;
  UserCreateFailure(this.message);
}
