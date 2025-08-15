import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class InvoiceException implements Exception {
  final String message;
  InvoiceException(this.message);
  @override
  String toString() => message;
}

class InvoiceApiClient {
  final ApiService apiService;
  InvoiceApiClient(this.apiService);

  Future<bool> paymentInvoice(String token, int invoiceId) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.paymentInvoice}/$invoiceId',
        token: token,
      );
      if (response.data['code'] != 200) return false;
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> paymentInvoiceKennel(String token, int invoiceId) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: '${EndPoints.paymentInvoiceKennel}/$invoiceId',
        token: token,
      );
      if (response.data['code'] != 200) return false;
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<InvoiceDto>> getInvoiceByDoctor(String token) async {
    // try {
    final response = await apiService.getRequest(
      url: EndPoints.getInvoicesByDoctor,
      token: token,
    );
    final data = response.data['data'] as List<dynamic>;
    if (data.isEmpty) {
      return [];
    } else {
      final invoices = (data).map((e) => InvoiceDto.fromJson(e)).toList();
      return invoices;
    }
    // } catch (e) {
    //   throw Exception(e);
    // }
  }

  Future<List<InvoiceResponse>> getInvoiceByUser(String token) async {
    // try {
    final response = await apiService.getRequest(
      url: EndPoints.getInvoiceByUser,
      token: token,
    );
    final data = response.data['data'] as List<dynamic>;
    if (data.isEmpty) {
      return [];
    } else {
      final invoices = (data).map((e) => InvoiceResponse.fromJson(e)).toList();
      return invoices;
    }
    // } catch (e) {
    //   throw Exception(e);
    // }
  }

  Future<List<InvoiceKennelDto>> getInvoiceKennelByDoctor(String token) async {
    // try {
    final response = await apiService.getRequest(
      url: EndPoints.getInvoiceKennelsByDoctor,
      token: token,
    );
    final data = response.data['data'] as List<dynamic>;
    if (data.isEmpty) {
      return [];
    } else {
      final invoices = (data).map((e) => InvoiceKennelDto.fromJson(e)).toList();
      return invoices;
    }
    // } catch (e) {
    //   throw Exception(e);
    // }
  }

  Future<List<InvoiceKennelDto>> getInvoiceKennelByUser(String token) async {
    final response = await apiService.getRequest(
      url: EndPoints.getInvoiceKennelsByUser,
      token: token,
    );
    final data = response.data['data'] as List<dynamic>;
    if (data.isEmpty) {
      return [];
    } else {
      final invoices = (data).map((e) => InvoiceKennelDto.fromJson(e)).toList();
      return invoices;
    }
  }

  Future<String> redirectPaymentVnpay(
    String token,
    VnPayRequestDto request,
  ) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.redirectVnpay,
        data: request.toJson(),
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data']['url'];
    } catch (e) {
      print(e);
      throw InvoiceException("Chuyển hướng Vnpay không thành công");
    }
  }
}
