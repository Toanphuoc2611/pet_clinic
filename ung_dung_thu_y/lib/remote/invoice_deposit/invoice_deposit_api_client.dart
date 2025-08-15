import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_appoint.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_kennel.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class InvoiceDepositApiClient {
  ApiService apiService;
  InvoiceDepositApiClient(this.apiService);

  Future<List<InvoiceDepositDto>> getInvoicesByUser(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getInvoiceDepositUser,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      } else {
        final invoices =
            (data).map((e) => InvoiceDepositDto.fromJson(e)).toList();
        return invoices;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> paymentInvoice(String token, int invoiceId) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.paymentInvoiceDeposit}/$invoiceId',
        token: token,
      );
      if (response.data['code'] != 200) return false;
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<InvoiceDepositKennel> getInvoiceDepoKennel(
    String token,
    int invoiceId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: '${EndPoints.getInvoiceDepositKennel}/$invoiceId',
        token: token,
      );
      final data = response.data['data'];
      if (data == null) {
        throw Exception('Không có dữ liệu');
      } else {
        return InvoiceDepositKennel.fromJson(response.data['data']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<InvoiceDepositAppoint> getInvoiceAppoint(
    String token,
    int invoiceId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: '${EndPoints.getInvoiceDepositAppoint}/$invoiceId',
        token: token,
      );
      final data = response.data['data'];
      if (data == null) {
        throw Exception('Không có dữ liệu');
      } else {
        return InvoiceDepositAppoint.fromJson(response.data['data']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
