import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class InstitutesApi {
  static final String? _apiBaseURL = dotenv.env['API_BASE_URL'];

  Future<List<Map<String, dynamic>>> fetchInstitutes({
    required String courseName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_apiBaseURL/institutes/search?courseName=${Uri.encodeComponent(courseName)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("❌ Failed to fetch institutes: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching institutes: $e");
      return [];
    }
  }
}
