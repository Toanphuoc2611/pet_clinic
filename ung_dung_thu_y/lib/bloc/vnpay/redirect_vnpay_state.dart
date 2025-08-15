sealed class RedirectVnpayState {}

class RedirectVnpayInitial extends RedirectVnpayState {}

class RedirectVnpayInProgress extends RedirectVnpayState {}

class RedirectVnpaySuccess extends RedirectVnpayState {
  final String url;
  RedirectVnpaySuccess(this.url);
}

class RedirectVnpayFailure extends RedirectVnpayState {
  final String message;
  RedirectVnpayFailure(this.message);
}
