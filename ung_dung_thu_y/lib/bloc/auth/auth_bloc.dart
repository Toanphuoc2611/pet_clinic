import 'package:bloc/bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_event.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthLoginStarted>(_onLoginStarted);
    on<AuthRegisterStarted>(_onRegisterStarted);
    on<AuthsendOtpStarted>(_onSendOtpStarted);
    on<AuthLogoutStarted>(_onLogoutStarted);
  }
  final AuthRepository authRepository;
  void _onLoginStarted(AuthLoginStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoginInProgress());
    final result = await authRepository.login(
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    return (switch (result) {
      Success() => emit(AuthLoginSuccess(result.data)),
      Failure() => emit(AuthLoginFailure(result.message)),
    });
  }

  void _onRegisterStarted(
    AuthRegisterStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthRegisterInProgress());
    final result = await authRepository.register(event.registerDto);
    return (switch (result) {
      Success() => emit(AuthRegisterSuccess()),
      Failure() => emit(AuthRegisterFailure(result.message)),
    });
  }

  void _onSendOtpStarted(
    AuthsendOtpStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSendOtpInProgress());
    final result = await authRepository.sendOtp(event.phoneNumber);
    return (switch (result) {
      Success() => emit(AuthSendOtpSuccess()),
      Failure() => emit(AuthSendOtpFailure(result.message)),
    });
  }

  void _onLogoutStarted(
    AuthLogoutStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLogoutInProgress());
    final result = await authRepository.logout();
    return (switch (result) {
      Success() => emit(AuthLogoutSuccess()),
      Failure() => emit(AuthLogoutFailure(result.message)),
    });
  }
}
