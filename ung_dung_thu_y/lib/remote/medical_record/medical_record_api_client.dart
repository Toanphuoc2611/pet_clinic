import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class MedicalRecordApiClient {
  final ApiService apiService;
  MedicalRecordApiClient(this.apiService);

  Future<List<MedicalRecordDto>> getMedicalRecords(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getListMedicalRecord,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((item) => MedicalRecordDto.fromJson(item)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<MedicalRecordDto> getMedicalRecordsByUser(
    String token,
    String petId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getMedicalRecordByUser}/$petId",
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return MedicalRecordDto.fromJson(data['data']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<MedicalRecordDto>> getListMedicalRecordByPet(
    String token,
    String petId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getListMedicalRecordByPet}/$petId",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((item) => MedicalRecordDto.fromJson(item)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
