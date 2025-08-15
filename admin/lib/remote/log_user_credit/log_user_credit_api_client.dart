import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/log_user_credit/log_user_credit_dto.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class LogUserCreditApiClient {
  LogUserCreditApiClient(this.apiService);
  final ApiService apiService;

  Future<List<LogUserCreditDto>> getLogByUserId(
    String token,
    String userId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: '${EndPoints.getLogUserCredit}/$userId',
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final logList =
          data
              .map(
                (item) =>
                    LogUserCreditDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return logList;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
