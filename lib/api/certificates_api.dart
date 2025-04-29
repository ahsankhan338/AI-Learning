import 'dart:convert';
import 'package:aieducator/models/certificate_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CertificatesApi {
  static final String? _apiBaseURL = dotenv.env['API_BASE_URL'];

  Future<List<Certificate>> fetchCertificates({required String token}) async {
    final response = await http.get(
      Uri.parse('$_apiBaseURL/certificates/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Certificate.fromJson(e)).toList();
    } else {
      print("❌ Failed to load certificates: ${response.body}");
      return [];
    }
  }

  Future<bool> generateCertificate({
    required String token,
    required String courseName,
    required String categoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseURL/certificates/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseName': courseName,
          'categoryId': categoryId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Error generating certificate: $e");
      return false;
    }
  }

  Future<bool> checkCertificateEligibility({
    required String token,
    required String categoryId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseURL/certificates/eligibility/$categoryId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['hasCertificate'] == true;
      } else {
        print("❌ Failed to check eligibility: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error checking certificate eligibility: $e");
      return false;
    }
  }
}
