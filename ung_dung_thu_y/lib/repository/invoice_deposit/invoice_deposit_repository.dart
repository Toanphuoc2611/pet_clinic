import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_appoint.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_kennel.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/invoice_deposit/invoice_deposit_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class InvoiceDepositRepository {
  final InvoiceDepositApiClient invoiceDepositApiClient;
  final AuthRepository authRepository;
  InvoiceDepositRepository(this.invoiceDepositApiClient, this.authRepository);
  Future<Result<List<InvoiceDepositDto>>> getInvoicesByUser() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceDepositApiClient.getInvoicesByUser(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<bool>> paymentInvoice(int invoiceId) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceDepositApiClient.paymentInvoice(
        token,
        invoiceId,
      );
      if (!result) return Failure("Thanh toán thất bại!");
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<InvoiceDepositKennel>> getInvoiceDepoKennel(
    int invoiceId,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceDepositApiClient.getInvoiceDepoKennel(
        token,
        invoiceId,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<InvoiceDepositAppoint>> getInvoiceDepoAppoint(
    int invoiceId,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceDepositApiClient.getInvoiceAppoint(
        token,
        invoiceId,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }
}
