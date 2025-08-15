import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/auth/login_dto.dart';
import 'package:ung_dung_thu_y/dto/auth/login_success_dto.dart';
import 'package:ung_dung_thu_y/dto/auth/register_dto.dart';

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
        data: {'email': loginDto.phoneNumber, 'password': loginDto.password},
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

  Future<LoginSuccessDto> refreshToken(String token) async {
    try {
      final response = await dio.post(
        EndPoints.refeshToken,
        data: {'token': token},
      );
      final data = response.data as Map<String, dynamic>;
      return LoginSuccessDto.fromJson(data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> register(RegisterDto registerDto) async {
    try {
      final response = await dio.post(
        EndPoints.register,
        data: registerDto.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['code'] == 205) {
        throw AuthException("OTP không chính xác");
      }
      if (data['data'].isEmpty) {
        return false;
      }
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw AuthException(e.response!.data['message']);
      } else {
        throw AuthException(e.message ?? 'Unknown error');
      }
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await dio.post(
        EndPoints.sendOtp,
        data: {'email': phoneNumber},
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw AuthException(e.response!.data['message']);
      } else {
        throw AuthException(e.message ?? 'Unknown error');
      }
    }
  }
}
