import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/user_event.dart';
import 'package:ung_dung_thu_y/bloc/user/user_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_dto.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this.userRepository) : super(UserInitial()) {
    on<UserGetStarted>(_onGetStarted);
    on<UserUpdatePrepare>(_onPrepare);
    on<UserUpdateStarted>(_onUpdateStarted);
    on<UserSearchStarted>(_onSearchStarted);
    on<UserSearchCleared>(_onSearchCleared);
    on<UserCreateStarted>(_onCreateStarted);
  }

  final UserRepository userRepository;

  void _onGetStarted(UserEvent event, Emitter<UserState> emit) async {
    emit(UserGetInProgress());
    final result = await userRepository.getUser();
    return (switch (result) {
      Success() => emit(UserGetSuccess(result.data)),
      Failure() => emit(UserGetFailure(result.message)),
    });
  }

  void _onPrepare(UserUpdatePrepare event, Emitter<UserState> emit) {
    emit(UserUpdateInitial(event.user));
  }

  void _onUpdateStarted(
    UserUpdateStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserUpdateInProgress());
    final result = await userRepository.updateUser(
      UserUpdateDto(
        id: event.id,
        fullname: event.fullname,
        birthday: event.birthday,
        gender: event.gender,
        address: event.address,
      ),
    );
    return (switch (result) {
      Success() => emit(UserUpdateSuccess()),
      Failure() => emit(UserUpdateFailure(result.message)),
    });
  }

  void _onSearchStarted(
    UserSearchStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserSearchInProgress());
    try {
      final result = await userRepository.searchUsers(event.query);
      switch (result) {
        case Success():
          emit(UserSearchSuccess(result.data));
          break;
        case Failure():
          emit(UserSearchFailure(result.message));
          break;
      }
    } catch (e) {
      emit(UserSearchFailure("Lỗi tìm kiếm: $e"));
    }
  }

  void _onSearchCleared(UserSearchCleared event, Emitter<UserState> emit) {
    emit(UserInitial());
  }

  void _onCreateStarted(
    UserCreateStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserCreateInProgress());
    try {
      print("UserBloc: Starting user creation");
      final result = await userRepository.createUser(event.userCreationRequest);
      print("UserBloc: Result type: ${result.runtimeType}");
      switch (result) {
        case Success():
          print("UserBloc: Success - User created: ${result.data}");
          emit(UserCreateSuccess(result.data));
          break;
        case Failure():
          print("UserBloc: Failure - ${result.message}");
          emit(UserCreateFailure(result.message));
          break;
      }
    } catch (e) {
      print("UserBloc: Exception caught: $e");
      emit(UserCreateFailure("Lỗi tạo người dùng: $e"));
    }
  }
}
