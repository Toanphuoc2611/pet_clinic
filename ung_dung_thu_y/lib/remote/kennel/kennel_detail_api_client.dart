import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/kennel/book_kennel_request.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class KennelDetailApiClient {
  final ApiService apiService;
  KennelDetailApiClient(this.apiService);

  Future<Map<String, dynamic>> bookKennel(
    String token,
    BookKennelRequest request,
  ) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.bookKennel,
        data: request.toJson(),
        token: token,
      );
      return response.data as Map<String, dynamic>;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<KennelDetailDto>> getAllKennelByUser(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllBookKennels,
        token: token,
      );
      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }
      final List<dynamic> data = response.data['data'];
      if (data.isEmpty || data == null) {
        return [];
      }
      return data.map((json) => KennelDetailDto.fromJson(json)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<KennelDetailDto> cancelBookKennel(String token, String id) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.cancelBookingKennel}/$id',
        token: token,
      );
      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }
      return KennelDetailDto.fromJson(response.data['data']);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<KennelDetailDto>> getKennelOfDoctorToday(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getKennelOfDoctorToday,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty || data == null) {
        return [];
      }
      return data.map((e) => KennelDetailDto.fromJson(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

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

  Future<KennelDetailDto> updateKennelStatus(
    String token,
    String id,
    String status,
  ) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.updateStatusKennel}/$id?status=$status',
        token: token,
      );
      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }
      return KennelDetailDto.fromJson(response.data['data']);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<InvoiceKennelDto> completeKennelBooking(
    String token,
    String id,
  ) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.completeKennelBooking}/$id',
        token: token,
      );
      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }
      return InvoiceKennelDto.fromJson(response.data['data']);
    } catch (error) {
      throw Exception(error);
    }
  }
}
