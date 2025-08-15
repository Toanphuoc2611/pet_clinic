import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/auth/login_dto.dart';
import 'package:admin/dto/auth/login_success_dto.dart';
import 'package:dio/dio.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthApiClient {
  AuthApiClient(this.dio);
  final Dio dio;

  Future<LoginSuccessDto> login(LoginDto loginDto) async {
    try {
      final response = await dio.post(
        EndPoints.login,
        data: {'email': loginDto.email, 'password': loginDto.password},
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == ('Password incorrect')) {
        throw AuthException('Mật khẩu không chính xác');
      } else if (data['message'] == ('USER NOT EXISTED')) {
        throw AuthException('Người dùng không tồn tại');
      }
      return LoginSuccessDto.fromJson(data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw AuthException('Lỗi đăng nhập vui lòng thử lại sau');
      } else {
        throw AuthException('Lỗi đăng nhập vui lòng thử lại sau');
      }
    }
  }

  Future<void> logout(String token) async {
    try {
      await dio.post(EndPoints.logout, data: {'token': token});
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
