import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/kennel/get_kennel_detail_dto.dart';
import 'package:admin/remote/api_service.dart';

class KennelDetailApiClient {
  final ApiService apiService;
  KennelDetailApiClient(this.apiService);

  Future<List<KennelDetailDto>> getKennelsByPetId(
    String token,
    String petId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: '${EndPoints.getKennelByPetId}/$petId',
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => KennelDetailDto.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
