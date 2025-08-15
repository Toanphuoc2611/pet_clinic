import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class InvoiceKennelException implements Exception {
  final String message;
  InvoiceKennelException(this.message);
  @override
  String toString() => message;
}

class InvoiceKennelApiClient {
  final ApiService apiService;
  InvoiceKennelApiClient(this.apiService);

  Future<int> getRevenue(String token, String start, String end) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getRevenueInvoiceKennel}?start=$start&end=$end",
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'];
    } on DioException catch (e) {
      if (e.response != null) {
        throw InvoiceKennelException('Lỗi khi tai du lieu');
      } else {
        throw InvoiceKennelException('Lỗi khi tai du lieu');
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
        url:
            "${EndPoints.getRevenueInvoiceKennel}/$doctorId?start=$start&end=$end",
        token: token,
      );
      final data = response.data as Map<String, dynamic>;
      return data['data'];
    } on DioException catch (e) {
      if (e.response != null) {
        throw InvoiceKennelException('Lỗi khi tai du lieu');
      } else {
        throw InvoiceKennelException('Lỗi khi tai du lieu');
      }
    }
  }

  Future<List<InvoiceKennelDto>> getAllInvoiceKennels(String token) async {
    // try {
    final response = await apiService.getRequest(
      url: EndPoints.getAllInvoiceKennels,
      token: token,
    );
    final data = response.data['data'] as List<dynamic>;
    if (data.isEmpty) return [];
    final listInvoices =
        data
            .map(
              (item) => InvoiceKennelDto.fromJson(item as Map<String, dynamic>),
            )
            .toList();
    return listInvoices;
    // } on DioException catch (e) {
    //   if (e.response != null) {
    //     throw Exception(e.response!.data['message']);
    //   } else {
    //     throw Exception(e.message);
    //   }
    // }
    // }
  }
}
