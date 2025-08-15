abstract class LogUserCreditEvent {}

class LogUserCreditGetByUserIdStarted extends LogUserCreditEvent {
  final String userId;
  LogUserCreditGetByUserIdStarted(this.userId);
}
