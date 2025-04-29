import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CourseApi {
  static final String? _apiBaseURL = dotenv.env['API_BASE_URL'];

  static Future<Map<String, dynamic>> fetchCourses(int page, int limit,
      {String? categoryId}) async {
    print("Courses: $categoryId");
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (categoryId != null) 'categoryId': categoryId.toString(),
    };

    final uri = Uri.parse('$_apiBaseURL/course/findCourses')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri);

    print("Courses: $response");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load courses');
    }
  }
}
