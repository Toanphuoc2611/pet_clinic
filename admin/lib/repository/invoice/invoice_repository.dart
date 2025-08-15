import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/invoice/invoice_response.dart';
import 'package:admin/remote/invoice/invoice_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class InvoiceRepository {
  final InvoiceApiClient invoiceApiClient;
  final AuthRepository authRepository;

  InvoiceRepository(this.invoiceApiClient, this.authRepository);

  Future<Result<int>> getRevenue(String start, String end) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getRevenue(token, start, end);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<int>> getRevenueByDoctor(
    String start,
    String end,
    String doctorId,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getRevenueByDoctor(
        token,
        start,
        end,
        doctorId,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<List<InvoiceResponse>> getAllInvoices() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      return await invoiceApiClient.getAllInvoice(token);
    } else {
      throw Exception("Error retrieving token");
    }
  }
}
