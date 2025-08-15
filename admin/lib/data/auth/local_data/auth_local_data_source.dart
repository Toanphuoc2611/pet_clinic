import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this.storage);
  final FlutterSecureStorage storage;

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      // Sử dụng SharedPreferences cho web
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } else {
      // Sử dụng FlutterSecureStorage cho mobile
      await storage.write(key: 'token', value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      // Sử dụng SharedPreferences cho web
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } else {
      // Sử dụng FlutterSecureStorage cho mobile
      return await storage.read(key: 'token');
    }
  }
}
