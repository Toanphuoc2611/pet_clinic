sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoginInProgress extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final Map<String, String> inforToken;
  AuthLoginSuccess(this.inforToken);
}

class AuthLoginFailure extends AuthState {
  AuthLoginFailure(this.message);
  final String message;
}

class AuthRegisterInProgress extends AuthState {}

class AuthRegisterSuccess extends AuthState {}

class AuthRegisterFailure extends AuthState {
  AuthRegisterFailure(this.message);
  final String message;
}

class AuthSendOtpInProgress extends AuthState {}

class AuthSendOtpSuccess extends AuthState {}

class AuthSendOtpFailure extends AuthState {
  AuthSendOtpFailure(this.message);
  final String message;
}

class AuthLogoutInProgress extends AuthState {}

class AuthLogoutSuccess extends AuthState {}

class AuthLogoutFailure extends AuthState {
  AuthLogoutFailure(this.message);
  final String message;
}
