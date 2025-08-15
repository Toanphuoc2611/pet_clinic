import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/user_credit/user_credit_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class UserCreditException implements Exception {
  final String message;
  UserCreditException(this.message);
  @override
  String toString() => message;
}

class UserCreditApiClient {
  final ApiService apiService;
  UserCreditApiClient(this.apiService);

  Future<UserCreditDto> getUserCredit(String token) async {
    final response = await apiService.getRequest(
      url: EndPoints.getUserCredit,
      token: token,
    );
    final data = response.data as Map<String, dynamic>;
    if (data['data'].isEmpty) {
      return throw UserCreditException("Không lấy được số dư");
    }
    return UserCreditDto.fromJson(data['data']);
  }
}
