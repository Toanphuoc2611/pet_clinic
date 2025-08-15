import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';
import 'package:ung_dung_thu_y/remote/invoice/invoice_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class InvoiceRepository {
  final InvoiceApiClient invoiceApiClient;
  final AuthRepository authRepository;

  InvoiceRepository(this.invoiceApiClient, this.authRepository);

  Future<Result<bool>> paymentInvoice(int invoiceId) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.paymentInvoice(token, invoiceId);
      if (!result) return Failure("Thanh toán thất bại!");
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<bool>> paymentInvoiceKennel(int invoiceId) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.paymentInvoiceKennel(
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

  Future<Result<List<InvoiceDto>>> getInvoicesByDocter() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getInvoiceByDoctor(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<InvoiceKennelDto>>> getInvoicesKennelsByDocter() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getInvoiceKennelByDoctor(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<InvoiceResponse>>> getInvoicesByUser() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getInvoiceByUser(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<InvoiceKennelDto>>> getInvoicesKennelsByUser() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.getInvoiceKennelByUser(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<String>> redirectPaymentVnpay(VnPayRequestDto request) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await invoiceApiClient.redirectPaymentVnpay(
        token,
        request,
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
