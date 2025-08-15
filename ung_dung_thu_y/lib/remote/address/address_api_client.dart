import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/address/Province.dart';
import 'package:ung_dung_thu_y/dto/address/district.dart';
import 'package:ung_dung_thu_y/dto/address/ward.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class AddressApiClient {
  ApiService apiService;
  AddressApiClient(this.apiService);

  Future<List<Province>> getProvinces() async {
    final response = await apiService.getRequestPublic(
      url: EndPoints.getProvinces,
    );
    if (response.statusCode == 200) {
      if (response.data['data'].isEmpty) {
        return [];
      }
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Province.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<District>> getDistricts(int provinceId) async {
    final response = await apiService.getRequestPublic(
      url: '${EndPoints.getDistricts}/$provinceId',
    );
    if (response.statusCode == 200) {
      if (response.data['data'].isEmpty) {
        return [];
      }
      final List<dynamic> data = response.data['data'];
      return data.map((json) => District.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<Ward>> getWards(int districtId) async {
    final response = await apiService.getRequestPublic(
      url: '${EndPoints.getWards}/$districtId',
    );
    if (response.statusCode == 200) {
      if (response.data['data'].isEmpty) {
        return [];
      }
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Ward.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wards');
    }
  }
}
