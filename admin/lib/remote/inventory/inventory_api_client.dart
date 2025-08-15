import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/inventory/Inventory_dto.dart';
import 'package:admin/dto/inventory/Medication_import_request.dart';
import 'package:admin/dto/inventory/import_inventory.dart';
import 'package:admin/dto/inventory/update_medication_status.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class InventoryApiClient {
  final ApiService apiService;
  InventoryApiClient(this.apiService);

  Future<List<InventoryDto>> getAllInventory(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getInvetory,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final list =
          data
              .map(
                (item) => InventoryDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return list;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> importInventory(String token, ImportInventory request) async {
    try {
      final response = await apiService.putRequest(
        data: request.toJson(),
        url: EndPoints.importInventory,
        token: token,
      );
      final data = response.data['data'];
      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> importMedcationNew(
    String token,
    MedicationImportRequest request,
  ) async {
    try {
      final response = await apiService.postRequest(
        data: request.toJson(),
        url: EndPoints.importInventory,
        token: token,
      );
      final data = response.data['data'];
      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> updateMedicationStatus(
    String token,
    UpdateMedicationStatus request,
  ) async {
    try {
      final response = await apiService.putRequest(
        data: request.toJson(),
        url: '${EndPoints.getInvetory}/status',
        token: token,
      );
      final data = response.data['data'];
      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
