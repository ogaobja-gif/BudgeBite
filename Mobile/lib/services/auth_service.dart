import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../utils/app_config.dart';

class ApiResult {
  final bool success;
  final String message;
  final String? status;
  final UserModel? user;
  final String? token;
  final String? devCode;
  final Map<String, String> errors;

  const ApiResult({
    required this.success,
    required this.message,
    this.status,
    this.user,
    this.token,
    this.devCode,
    this.errors = const {},
  });

  factory ApiResult.fail(String message) => ApiResult(success: false, message: message);

  factory ApiResult.fromJson(Map<String, dynamic> j) {
    final errs = <String, String>{};
    if (j['errors'] is Map) {
      (j['errors'] as Map).forEach((k, v) => errs['$k'] = '$v');
    }
    return ApiResult(
      success: j['success'] == true,
      message: j['message']?.toString() ?? '',
      status: j['status']?.toString(),
      user: j['user'] is Map ? UserModel.fromJson(Map<String, dynamic>.from(j['user'] as Map)) : null,
      token: j['token']?.toString(),
      devCode: j['dev_code']?.toString(),
      errors: errs,
    );
  }
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'remember_token';

  static Future<ApiResult> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final r = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(r.body);
      if (decoded is Map<String, dynamic>) return ApiResult.fromJson(decoded);
      return ApiResult.fail('Unexpected server response.');
    } on TimeoutException {
      return ApiResult.fail('The server took too long to respond. Please try again.');
    } on SocketException {
      return ApiResult.fail('Cannot reach the server. Make sure XAMPP (Apache + MySQL) is running and the API address is correct.');
    } on FormatException {
      return ApiResult.fail('The server sent an invalid response. Check the PHP files and the XAMPP error log.');
    } catch (_) {
      return ApiResult.fail('Cannot connect to the server. Please try again.');
    }
  }

  static Future<ApiResult> login(String identifier, String password, bool remember) async {
    final res = await _post('login.php', {
      'identifier': identifier.trim(),
      'password': password,
      'remember': remember,
    });
    if (res.success) {
      if (remember && res.token != null) {
        await _storage.write(key: _tokenKey, value: res.token);
      } else {
        await _storage.delete(key: _tokenKey);
      }
    }
    return res;
  }

  static Future<ApiResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String username,
    required String password,
    required String accountType,
  }) =>
      _post('register.php', {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone_number': phone.trim(),
        'username': username.trim(),
        'password': password,
        'account_type': accountType,
      });

  static Future<ApiResult> forgotPassword(String email) => _post('forgot_password.php', {'email': email.trim()});

  static Future<ApiResult> resetPassword(String email, String code, String password) =>
      _post('reset_password.php', {'email': email.trim(), 'code': code.trim(), 'password': password});

  /// Remember Me: returns the saved user if a valid token is stored on the device.
  static Future<UserModel?> autoLogin() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return null;
      final res = await _post('session.php', {'token': token});
      if (res.success) return res.user;
      if (res.status == 'invalid') await _storage.delete(key: _tokenKey);
    } catch (_) {}
    return null;
  }

  static Future<void> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) await _post('logout.php', {'token': token});
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
