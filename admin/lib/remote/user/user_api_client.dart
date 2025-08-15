import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/user/user_get_dto.dart';
import 'package:admin/dto/user/user_response.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class UserApiClient {
  UserApiClient(this.apiService);
  final ApiService apiService;

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

  Future<List<UserResponse>> getListCustomer(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getListCustomer,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listCustomer =
          data
              .map(
                (item) => UserResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return listCustomer;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
