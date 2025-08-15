import 'dart:developer';

import 'package:admin/data/auth/local_data/auth_local_data_source.dart';
import 'package:admin/dto/auth/login_dto.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/auth/auth_api_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepository {
  final AuthApiClient authApiClient;
  final AuthLocalDataSource authLocalDataSource;
  AuthRepository({
    required this.authApiClient,
    required this.authLocalDataSource,
  });
  Future<Result<Map<String, String>>> login({
    required email,
    required password,
  }) async {
    try {
      final loginSuccessDto = await authApiClient.login(
        LoginDto(email: email, password: password),
      );
      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        loginSuccessDto.token,
      );
      await authLocalDataSource.saveToken(loginSuccessDto.token);
      return Success({
        'userId': decodedToken['sub'],
        'role': decodedToken['scope'],
      });
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<String>> getToken() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Failure("Token not found");
      }
      return Success(token);
    } catch (e) {
      log('$e');
      return Failure('$e');
    }
  }

  Future<Result<void>> logout() async {
    try {
      final tokenResult = await getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        await authApiClient.logout(token);
        await authLocalDataSource.saveToken("");
        return Success(null);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Đăng xuất không thành công");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
