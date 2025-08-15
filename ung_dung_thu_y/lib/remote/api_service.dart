import 'dart:developer';

import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;
  ApiService(this.dio);
  Future<Response> postRequest({
    required String url,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  Future<Response> getRequest({
    required String url,
    required String token,
  }) async {
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  // This method is used for public GET requests that do not require authentication.
  Future<Response> getRequestPublic({required String url}) async {
    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  Future<Response> putRequest({
    required String url,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    try {
      final response = await dio.put(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  Future<Response> putRequestWithoutData({
    required String url,
    required String token,
  }) async {
    try {
      final response = await dio.put(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  Future<Response> deleteRequestWithoutData({
    required String url,
    required String token,
  }) async {
    try {
      final response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }
}
