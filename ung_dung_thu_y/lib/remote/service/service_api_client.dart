import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class ServiceApiClient {
  final ApiService apiService;
  ServiceApiClient(this.apiService);

  Future<List<ServicesGetDto>> getAllServices(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllServices,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listService =
          data
              .map(
                (item) => ServicesGetDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return listService;
    } on DioException catch (e) {
      if (e.response != null) {
        return throw Exception(e.response!.data['message']);
      } else {
        return throw Exception(e.message);
      }
    }
  }
}
