import 'package:ung_dung_thu_y/dto/user_credit/user_credit_dto.dart';

sealed class UserCreditState {}

class UserCreditInitial extends UserCreditState {}

class UserCreditGetInProgress extends UserCreditState {}

class UserCreditGetSuccess extends UserCreditState {
  final UserCreditDto userCredits;
  UserCreditGetSuccess(this.userCredits);
}

class UserCreditGetFailure extends UserCreditState {
  final String message;
  UserCreditGetFailure({required this.message});
}
