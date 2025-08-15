import 'package:admin/bloc/log_user_credit/log_user_credit_event.dart';
import 'package:admin/bloc/log_user_credit/log_user_credit_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/log_user_credit/log_user_credit_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogUserCreditBloc extends Bloc<LogUserCreditEvent, LogUserCreditState> {
  final LogUserCreditRepository logUserCreditRepository;

  LogUserCreditBloc(this.logUserCreditRepository)
    : super(LogUserCreditInitial()) {
    on<LogUserCreditGetByUserIdStarted>(_onGetByUserIdStarted);
  }

  void _onGetByUserIdStarted(
    LogUserCreditGetByUserIdStarted event,
    Emitter<LogUserCreditState> emit,
  ) async {
    emit(LogUserCreditGetInProgress());
    var result = await logUserCreditRepository.getLogByUserId(event.userId);
    return (switch (result) {
      Success() => emit(LogUserCreditGetByUserIdSuccess(result.data)),
      Failure() => emit(LogUserCreditGetFailure(result.message)),
    });
  }
}
