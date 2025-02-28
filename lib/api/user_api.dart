import 'dart:convert';
import 'package:aieducator/models/user_modal.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static const String _apiBaseURL = 'http://10.0.2.2:3001'; // Make static

  static Future<User> getUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseURL/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
}
