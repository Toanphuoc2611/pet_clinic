import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/service/creation_service.dart';
import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/remote/api_service.dart';

class ServiceApiClient {
  final ApiService apiService;
  ServiceApiClient(this.apiService);

  Future<List<ServicesGetDto>> getAllServices(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllService,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => ServicesGetDto.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> updateService(String token, String id, int price) async {
    try {
      final response = await apiService.putRequest(
        url: "${EndPoints.services}/$id",
        data: {'price': price},
        token: token,
      );
      final data = response.data['data'];
      return data;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> updateStatusService(String token, String id, int status) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: "${EndPoints.services}/$id/status?status=$status",
        token: token,
      );
      final data = response.data['data'];
      return data;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> addService(String token, CreationService request) async {
    try {
      final Map<String, dynamic> data = {
        'name': request.name,
        'price': request.price,
      };
      final response = await apiService.postRequest(
        url: EndPoints.services,
        data: data,
        token: token,
      );
      final responseData = response.data['data'];
      return responseData;
    } catch (error) {
      throw Exception(error);
    }
  }
}
