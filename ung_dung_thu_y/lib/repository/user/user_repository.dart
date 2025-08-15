import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/user/user_creation_request.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_dto.dart';
import 'package:ung_dung_thu_y/remote/user/user_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class UserRepository {
  final AuthRepository authRepository;
  final UserApiClient userApiClient;
  UserRepository({required this.authRepository, required this.userApiClient});
  Future<Result<UserGetDto>> getUser() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final userGetDto = await userApiClient.getUser(token);
        return Success(userGetDto);
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

  Future<Result<UserGetDto>> updateUser(UserUpdateDto request) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final result = await userApiClient.updateUser(request, token);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

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

  Future<Result<List<UserGetDto>>> searchUsers(String query) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final users = await userApiClient.searchUsers(query, token);
        return Success(users);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error search users");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<UserGetDto>> createUser(UserCreationRequest request) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final user = await userApiClient.createUser(request, token);
        return Success(user);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error creating user");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
