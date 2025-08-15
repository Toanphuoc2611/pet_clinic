import 'package:admin/dto/user/user_response.dart';

sealed class UserState {}

class UserInitial extends UserState {}

class UserGetCustomerInProgress extends UserState {}

class UserGeCustomerSuccess extends UserState {
  final List<UserResponse> customers;
  UserGeCustomerSuccess(this.customers);
}

class UserGetCustomerFailure extends UserState {
  final String message;
  UserGetCustomerFailure(this.message);
}
