import 'dart:convert';
import 'package:aieducator/models/user_modal.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static const String _apiBaseURL = 'http://10.0.2.2:3001';

  static Future<User> getUser(String token) async {
    try {
      print("User: $token");
      final response = await http.get(
        Uri.parse('$_apiBaseURL/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print("User: $userData");
        return User.fromJson(userData);
      } else {
        print("User:${response.statusCode}");
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
}
