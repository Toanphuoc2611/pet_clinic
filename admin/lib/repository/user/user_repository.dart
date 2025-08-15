import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/user/user_get_dto.dart';
import 'package:admin/dto/user/user_response.dart';
import 'package:admin/remote/user/user_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class UserRepository {
  final AuthRepository authRepository;
  final UserApiClient userApiClient;
  UserRepository({required this.authRepository, required this.userApiClient});
  Future<Result<List<UserGetDto>>> getListDoctors() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final listDoctors = await userApiClient.getListDoctors(token);
        return Success(listDoctors);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error get user");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<UserResponse>>> getListCustomers() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final listCustomer = await userApiClient.getListCustomer(token);
        return Success(listCustomer);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error get user");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
