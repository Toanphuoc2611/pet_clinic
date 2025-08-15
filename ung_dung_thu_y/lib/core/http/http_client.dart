import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';

final dio = Dio(BaseOptions(baseUrl: EndPoints.baseUrl));
