import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/kennel/get_kennel_dto.dart';
import 'package:admin/dto/kennel/creation_kennel.dart';
import 'package:admin/remote/kennel/kennel_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class KennelRepository {
  final KennelApiClient kennelApiClient;
  final AuthRepository authRepository;
  KennelRepository(this.kennelApiClient, this.authRepository);

  Future<List<KennelDto>> getAllKennels() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await kennelApiClient.getAllKennel(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<List<KennelDto>> getValidKennels() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await kennelApiClient.getKennels(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> addKennel(CreationKennel request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await kennelApiClient.addKennel(token.data, request);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> updateKennelStatus(String id, String status) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await kennelApiClient.updateKennel(token.data, id, status);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
