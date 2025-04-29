import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

class Authentication {
  final String? _apiBaseURL = dotenv.env['API_BASE_URL'];

  Future<Map<String, dynamic>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_apiBaseURL/authentication/login');
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
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String dateOfBirth,
  }) async {
    try {
      final uri = Uri.parse('$_apiBaseURL/authentication/register');
      final Response response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'displayName': username,
              'password': password,
              'dateOfBirth': dateOfBirth,
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

      throw Exception('Registration Failed: ${responseBody['message']}');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
