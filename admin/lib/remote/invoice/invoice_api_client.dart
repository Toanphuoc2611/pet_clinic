import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/invoice/invoice_response.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class InvoiceException implements Exception {
  final String message;
  InvoiceException(this.message);
  @override
  String toString() => message;
}

class InvoiceApiClient {
  final ApiService apiService;
  InvoiceApiClient(this.apiService);

  Future<int> getRevenue(String token, String start, String end) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getRevenueInvoice}?start=$start&end=$end",
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'];
    } on DioException catch (e) {
      if (e.response != null) {
        throw InvoiceException('Lỗi khi tai du lieu');
      } else {
        throw InvoiceException('Lỗi khi tai du lieu');
      }
    }
  }

  Future<int> getRevenueByDoctor(
    String token,
    String start,
    String end,
    String doctorId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getRevenueInvoice}/$doctorId?start=$start&end=$end",
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'];
    } on DioException catch (e) {
      if (e.response != null) {
        throw InvoiceException('Lỗi khi tai du lieu');
      } else {
        throw InvoiceException('Lỗi khi tai du lieu');
      }
    }
  }

  Future<List<InvoiceResponse>> getAllInvoice(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllInvoices,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listInvoices =
          data
              .map(
                (item) =>
                    InvoiceResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return listInvoices;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
