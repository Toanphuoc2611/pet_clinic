import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/inventory/Inventory_dto.dart';
import 'package:admin/dto/inventory/import_inventory.dart';
import 'package:admin/dto/inventory/Medication_import_request.dart';
import 'package:admin/dto/inventory/update_medication_status.dart';
import 'package:admin/remote/inventory/inventory_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class InventoryRepository {
  final InventoryApiClient inventoryApiClient;
  final AuthRepository authRepository;

  InventoryRepository(this.inventoryApiClient, this.authRepository);

  Future<List<InventoryDto>> getAllInventory() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await inventoryApiClient.getAllInventory(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> importInventory(ImportInventory request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await inventoryApiClient.importInventory(token.data, request);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> importMedicationNew(MedicationImportRequest request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await inventoryApiClient.importMedcationNew(token.data, request);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> updateMedicationStatus(UpdateMedicationStatus request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await inventoryApiClient.updateMedicationStatus(
        token.data,
        request,
      );
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
