import 'package:firebase_auth/firebase_auth.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/user_credit/user_credit_dto.dart';
import 'package:ung_dung_thu_y/remote/user_credit/user_credit_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class UserCreditRepository {
  final UserCreditApiClient userCreditApiClient;
  final AuthRepository authRepository;

  UserCreditRepository(this.userCreditApiClient, this.authRepository);

  Future<Result<UserCreditDto>> getUserCredit() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await userCreditApiClient.getUserCredit(token);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        throw UserCreditException(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
