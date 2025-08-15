import 'package:admin/dto/log_user_credit/log_user_credit_dto.dart';

abstract class LogUserCreditState {}

class LogUserCreditInitial extends LogUserCreditState {}

class LogUserCreditGetInProgress extends LogUserCreditState {}

class LogUserCreditGetByUserIdSuccess extends LogUserCreditState {
  final List<LogUserCreditDto> logList;
  LogUserCreditGetByUserIdSuccess(this.logList);
}

class LogUserCreditGetFailure extends LogUserCreditState {
  final String message;
  LogUserCreditGetFailure(this.message);
}
