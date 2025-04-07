import 'dart:convert';

import 'package:http/http.dart' as http;

class CourseApi {
  static const String _apiBaseURL = 'http://10.0.2.2:3001/course/findCourses';

  static Future<Map<String, dynamic>> fetchCourses(int page, int limit,
      {String? categoryId}) async {

    print("Courses: $categoryId");    
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (categoryId != null) 'categoryId': categoryId.toString(),
    };

    final uri = Uri.parse(_apiBaseURL).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    print("Courses: $response");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load courses');
    }
  }
}
