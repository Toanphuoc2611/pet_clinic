import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_by_doctor.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class PrescriptionException implements Exception {
  final String message;
  PrescriptionException(this.message);
  @override
  String toString() => message;
}

class PrescriptionApiClient {
  final ApiService apiService;
  PrescriptionApiClient(this.apiService);

  Future<InvoiceResponse> createPrescription(
    String token,
    CreationPrescriptionReq request,
  ) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.createPrescription,
        data: request.toJson(),
        token: token,
      );
      if (response.data['code'] != 200) {
        if (response.data['code'] == 409) {
          throw PrescriptionException("Không đủ thuốc trong kho");
        }
      }
      final data = response.data as Map<String, dynamic>;
      return InvoiceResponse.fromJson(data['data']);
    } catch (e) {
      throw PrescriptionException("Không thể tạo đơn thuốc");
    }
  }

  Future<InvoiceResponse> createPrescriptionByDoctor(
    String token,
    PrescriptionCreationByDoctor request,
  ) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.createPrescriptionByDoctor,
        data: request.toJson(),
        token: token,
      );
      if (response.data['code'] != 200) {
        if (response.data['code'] == 409) {
          throw PrescriptionException("Không đủ thuốc trong kho");
        }
      }
      final data = response.data as Map<String, dynamic>;
      return InvoiceResponse.fromJson(data['data']);
    } catch (e) {
      throw PrescriptionException("Không thể tạo đơn thuốc");
    }
  }

  Future<List<PrescriptionDto>> getPrescriptionsByPetId(
    String token,
    int medicalRecordId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getPrescriptionsByMedicalRecord}/$medicalRecordId",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return (data).map((item) => PrescriptionDto.fromJson(item)).toList();
    } catch (e) {
      throw PrescriptionException("Không thể lấy dữ liệu");
    }
  }
}
