import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/dto/service/creation_service.dart';
import 'package:admin/remote/service/service_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class ServiceRepository {
  final AuthRepository authRepository;
  final ServiceApiClient serviceApiClient;
  ServiceRepository(this.authRepository, this.serviceApiClient);

  Future<List<ServicesGetDto>> getAllServices() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await serviceApiClient.getAllServices(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> addService(CreationService request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await serviceApiClient.addService(token.data, request);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> updateService(String id, int price) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await serviceApiClient.updateService(token.data, id, price);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> updateServiceStatus(String id, int status) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await serviceApiClient.updateStatusService(token.data, id, status);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
