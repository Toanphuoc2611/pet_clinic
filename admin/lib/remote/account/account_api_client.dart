import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/account/account_dto.dart';
import 'package:admin/dto/account/create_doctor_request.dart';
import 'package:admin/dto/account/update_account_status_request.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class AccountApiClient {
  final ApiService apiService;
  AccountApiClient(this.apiService);

  Future<List<AccountDto>> getAllAccounts(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllAccount,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final list =
          data
              .map((item) => AccountDto.fromJson(item as Map<String, dynamic>))
              .toList();
      return list;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> createDoctorAccount(
    String token,
    CreateDoctorRequest request,
  ) async {
    // try {
    final response = await apiService.postRequest(
      data: request.toJson(),
      url: EndPoints.createAccount,
      token: token,
    );
    return response.statusCode == 200 || response.statusCode == 201;
    // } on DioException catch (e) {
    //   if (e.response != null) {
    //     throw Exception(e.response!.data['message']);
    //   } else {
    //     throw Exception(e.message);
    //   }
    // }
  }

  Future<bool> updateAccountStatus(String token, int id, int status) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.getAllAccount}/$id?status=$status',
        token: token,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
