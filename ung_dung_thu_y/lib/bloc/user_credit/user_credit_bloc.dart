import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_event.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/user_credit/user_credit_repository.dart';

class UserCreditBloc extends Bloc<UserCreditEvent, UserCreditState> {
  final UserCreditRepository userCreditRepository;
  UserCreditBloc(this.userCreditRepository) : super(UserCreditInitial()) {
    on<UserCreditGetStarted>(_onGetStarted);
  }

  void _onGetStarted(
    UserCreditGetStarted event,
    Emitter<UserCreditState> emit,
  ) async {
    emit(UserCreditGetInProgress());
    var result = await userCreditRepository.getUserCredit();

    return (switch (result) {
      Success() => emit(UserCreditGetSuccess(result.data)),
      Failure(message: final message) => emit(
        UserCreditGetFailure(message: message),
      ),
    });
  }
}
