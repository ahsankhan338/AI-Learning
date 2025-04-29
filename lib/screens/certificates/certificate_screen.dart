import 'package:aieducator/api/certificates_api.dart';
import 'package:aieducator/models/certificate_model.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/provider/routes_refresh_notifier.dart';
import 'package:aieducator/utility/go_router_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late Future<List<Certificate>> _futureCertificates;
  RoutesRefreshNotifier? _notifier;
  late CertificatesApi _certificatesApi;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _certificatesApi = CertificatesApi();
    _futureCertificates =
        _certificatesApi.fetchCertificates(token: authProvider.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier ??= Provider.of<RoutesRefreshNotifier>(context, listen: false);
    _notifier?.addListener(_handleRefresh);
  }

  @override
  void dispose() {
    _notifier?.removeListener(_handleRefresh);
    super.dispose();
  }

  void _handleRefresh() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        _futureCertificates = _certificatesApi.fetchCertificates(
            token: authProvider.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("📃 CertificateScreen BUILD");

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FutureBuilder<List<Certificate>>(
        future: _futureCertificates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No certificates yet",
                  style: TextStyle(color: Colors.white)),
            );
          } else {
            final certificates = snapshot.data!;
            return ListView.builder(
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: buildNotificationCard(
                    context: context,
                    title: "🎓 Congratulations!",
                    message: "You completed the course: ${cert.courseName}",
                    certificateUrl: cert.certificateUrl,
                    buttonText: "Preview Certificate",
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget buildNotificationCard({
    required String title,
    required String message,
    required String buttonText,
    required String certificateUrl,
    required BuildContext context,
  }) {
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
