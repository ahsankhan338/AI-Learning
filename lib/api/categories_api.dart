import 'dart:convert';

import 'package:aieducator/models/category_modal.dart';
import 'package:http/http.dart' as http;

class CategoriesApi {
  static const String _apiBaseURL = 'http://10.0.2.2:3001';

  static Future<List<Category>> getCategories({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseURL/categories/get3Categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Add validation
        if (responseData.isEmpty) {
          throw Exception('Received empty categories list');
        }

        print("Response Data: $responseData");

        final List<Category> result = responseData.map<Category>((jsonItem) {
          try {
            return Category.fromJson(jsonItem);
          } catch (e) {
            throw Exception('Failed to parse category: $e');
          }
        }).toList();
        print("result:: $result");
        return result;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
