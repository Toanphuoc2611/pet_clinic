import 'package:admin/bloc/auth/auth_event.dart';
import 'package:admin/bloc/auth/auth_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/auth/auth_repository.dart';
import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthLoginStarted>(_onLoginStarted);
    on<AuthLogoutStarted>(_onLogoutStarted);
  }
  final AuthRepository authRepository;
  void _onLoginStarted(AuthLoginStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoginInProgress());
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );

    return (switch (result) {
      Success() => emit(AuthLoginSuccess(result.data)),
      Failure() => emit(AuthLoginFailure(result.message)),
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
