import 'package:admin/core/endpoints/end_points.dart';
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(baseUrl: EndPoints.baseUrl));
