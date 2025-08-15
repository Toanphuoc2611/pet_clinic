import 'package:admin/bloc/user/user_event.dart';
import 'package:admin/bloc/user/user_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/user/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  UserBloc(this.userRepository) : super(UserInitial()) {
    on<UserGetCustomerStarted>(_onGetCustomerStarted);
  }

  void _onGetCustomerStarted(
    UserGetCustomerStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserGetCustomerInProgress());
    var result = await userRepository.getListCustomers();
    return (switch (result) {
      Success() => emit(UserGeCustomerSuccess(result.data)),
      Failure() => emit(UserGetCustomerFailure(result.message)),
    });
  }
}
