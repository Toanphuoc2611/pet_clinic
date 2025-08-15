import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/log_user_credit/log_user_credit_dto.dart';
import 'package:admin/remote/log_user_credit/log_user_credit_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class LogUserCreditRepository {
  final AuthRepository authRepository;
  final LogUserCreditApiClient logUserCreditApiClient;

  LogUserCreditRepository({
    required this.authRepository,
    required this.logUserCreditApiClient,
  });

  Future<Result<List<LogUserCreditDto>>> getLogByUserId(String userId) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final logList = await logUserCreditApiClient.getLogByUserId(
          token,
          userId,
        );
        return Success(logList);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error getting token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
