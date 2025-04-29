import 'dart:convert';
import 'package:aieducator/models/certificate_model.dart';
import 'package:aieducator/provider/routes_refresh_notifier.dart';
import 'package:aieducator/utility/go_router_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen>
    with ChangeNotifier {
  List<Certificate> certificates = [];
  bool isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCertificates();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCertificates(); // Always fetch fresh when dependencies change
  }

  Future<void> fetchCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3001/certificates/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        certificates = data.map((e) => Certificate.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      print("Failed to load certificates: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutesRefreshNotifier>(
      builder: (context, notifier, child) {
        fetchCertificates();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : certificates.isEmpty
                  ? const Center(
                      child: Text("No certificates yet",
                          style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        final cert = certificates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildNotificationCard(
                            context: context,
                            title: "🎓 Congratulations!",
                            message:
                                "You completed the course: ${cert.courseName}",
                            certificateUrl: cert.certificateUrl,
                            buttonText: "Preview Certificate",
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget buildNotificationCard(
      {required String title,
      required String message,
      required String buttonText,
      required String certificateUrl,
      required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed(
                  AppRoutes.certificatePreview.name,
                  queryParameters: {
                    'url': certificateUrl,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D3CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
