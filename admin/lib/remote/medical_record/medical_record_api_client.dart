import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/medical_record/medical_record_dto.dart';
import 'package:admin/remote/api_service.dart';

class MedicalRecordApiClient {
  final ApiService apiService;
  MedicalRecordApiClient(this.apiService);

  Future<List<MedicalRecordDto>> getAllMedicalRecords(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllMedicalRecords,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((item) => MedicalRecordDto.fromJson(item)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
