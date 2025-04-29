import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewCertificateScreen extends StatefulWidget {
  final String pdfUrl;
  const PreviewCertificateScreen({super.key, required this.pdfUrl});

  @override
  State<PreviewCertificateScreen> createState() =>
      _PreviewCertificateScreenState();
}

class _PreviewCertificateScreenState extends State<PreviewCertificateScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      // light background
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SfPdfViewer.network(

              widget.pdfUrl,
              onDocumentLoaded: (_) {
                setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to load certificate."),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => _isLoading = false);
              },
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
          ],
        ),
      ),
    );
  }
}
