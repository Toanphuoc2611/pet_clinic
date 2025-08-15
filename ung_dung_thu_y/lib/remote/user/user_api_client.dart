import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/user/user_creation_request.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class UserApiClient {
  UserApiClient(this.apiService);
  final ApiService apiService;

  Future<UserGetDto> getUser(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getUser,
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return UserGetDto.fromJson(data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<UserGetDto> updateUser(UserUpdateDto request, String token) async {
    try {
      final data = {
        "id": request.id,
        "fullname": request.fullname,
        "birthday": request.birthday,
        "gender": request.gender,
        "address": request.address,
      };
      final response = await apiService.putRequest(
        url: EndPoints.getUser,
        data: data,
        token: token,
      );
      final user = response.data as Map<String, dynamic>;
      return UserGetDto.fromJson(user['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<UserGetDto>> getListDoctors(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getListDoctor,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listDoctors =
          data
              .map((item) => UserGetDto.fromJson(item as Map<String, dynamic>))
              .toList();
      return listDoctors;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<UserGetDto>> searchUsers(String query, String token) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.searchUsers}?query=$query",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final users =
          data
              .map((item) => UserGetDto.fromJson(item as Map<String, dynamic>))
              .toList();
      return users;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<UserGetDto> createUser(
    UserCreationRequest request,
    String token,
  ) async {
    try {
      print("Creating user with data: ${request.toJson()}");
      print("URL: ${EndPoints.baseUrl}/users");
      print("Token: $token");

      final response = await apiService.postRequest(
        url: "${EndPoints.baseUrl}/users",
        data: request.toJson(),
        token: token,
      );

      print("Response: ${response.data}");
      final data = response.data as Map<String, dynamic>;
      return UserGetDto.fromJson(data['data']);
    } on DioException catch (e) {
      print("DioException: ${e.response?.data}");
      print("DioException message: ${e.message}");
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      print("General exception: $e");
      throw Exception("Unexpected error: $e");
    }
  }
}
