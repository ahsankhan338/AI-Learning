import 'dart:convert';
import 'package:aieducator/models/user_modal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static final String? _apiBaseURL = dotenv.env['API_BASE_URL'];

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
        print("User: ${response.statusCode}");
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // ✅ New method to update user name
  static Future<String?> updateUserName(String token, String newName) async {
    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseURL/users/updateName'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        return null; // success
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Update failed';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
