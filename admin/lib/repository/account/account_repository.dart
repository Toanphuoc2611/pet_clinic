import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/account/account_dto.dart';
import 'package:admin/dto/account/create_doctor_request.dart';
import 'package:admin/dto/account/update_account_status_request.dart';
import 'package:admin/remote/account/account_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';
import 'package:admin/dto/user/user_get_dto.dart';

class AccountRepository {
  final AccountApiClient accountApiClient;
  final AuthRepository authRepository;

  AccountRepository(this.accountApiClient, this.authRepository);

  Future<List<AccountDto>> getAllAccounts() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await accountApiClient.getAllAccounts(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> createDoctorAccount(CreateDoctorRequest request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await accountApiClient.createDoctorAccount(token.data, request);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }

  Future<bool> updateAccountStatus(UpdateAccountStatusRequest request) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await accountApiClient.updateAccountStatus(
        token.data,
        request.accountId,
        request.status,
      );
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
