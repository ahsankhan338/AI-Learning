import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aieducator/models/quiz_model.dart';

class QuizApi {
  static const String _apiBaseURL = 'http://10.0.2.2:3001/quizes';

  // Get user's quiz titles for a specific category
  static Future<List<QuizTitle>?> getQuizTitles({
    required String token,
    required String categoryId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseURL/user-quiz/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['titles'] != null) {
          return (data['titles'] as List)
              .map((item) => QuizTitle.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching quiz titles: $e');
      return null;
    }
  }

  // Save quiz titles for a user's category
  static Future<bool> saveQuizTitles({
    required String token,
    required String categoryId,
    required List<QuizTitle> quizTitles,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseURL/save'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'categoryId': categoryId,
          'titles': quizTitles.map((title) => title.toJson()).toList(),
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error saving quiz titles: $e');
      return false;
    }
  }

  // Update quiz status (locked, unlocked, passed, failed)
  static Future<bool> updateQuizStatus({
    required String token,
    required String categoryId,
    required String quizTitle,
    required String previousTitle,
    required String previousTitleStatus,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseURL/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'categoryId': categoryId,
          'quizTitle': quizTitle,
          'previousTitle': previousTitle,
          'previousTitleStatus': previousTitleStatus,
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating quiz status: $e');
      return false;
    }
  }

  // Get the user's token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
