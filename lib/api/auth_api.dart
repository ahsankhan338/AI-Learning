import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

class Authentication {
  static const String apiBaseURL = 'http://10.0.2.2:3001';
  // For mobile apps, use 10.0.2.2 for Android emulator or actual IP for physical devices
  Future<Map<String, dynamic>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$apiBaseURL/authentication/login');
      final Response response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'message': responseBody['message'],
          'token': responseBody['accessToken']
        };
      }

      throw Exception('LoggedIn Failed ${responseBody['message']}');
    } catch (e) {
      throw Exception(e);
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
