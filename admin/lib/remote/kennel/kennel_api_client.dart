import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/kennel/creation_kennel.dart';
import 'package:admin/dto/kennel/get_kennel_dto.dart';
import 'package:admin/remote/api_service.dart';

class KennelApiClient {
  final ApiService apiService;
  KennelApiClient(this.apiService);

  Future<List<KennelDto>> getKennels(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllKennelValid,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => KennelDto.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<KennelDto>> getAllKennel(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllKennelAll,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => KennelDto.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> updateKennel(String token, String id, String status) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: "${EndPoints.getAllKennelValid}/$id?status=$status",
        token: token,
      );
      final data = response.data['data'];
      return data;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> addKennel(String token, CreationKennel request) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.getAllKennelValid,
        data: request.toJson(),
        token: token,
      );
      final data = response.data['data'];
      return data;
    } catch (error) {
      throw Exception(error);
    }
  }
}
