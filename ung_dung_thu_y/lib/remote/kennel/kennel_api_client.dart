import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class KennelApiClient {
  final ApiService apiService;
  KennelApiClient(this.apiService);

  Future<List<KennelDto>> getKennels(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getKennels,
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
}
