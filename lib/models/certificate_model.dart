class Certificate {
  final String courseName;
  final String categoryId;
  final String issuedAt;
  final String certificateUrl;

  Certificate({
    required this.courseName,
    required this.categoryId,
    required this.issuedAt,
    required this.certificateUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    final String rawUrl = json['certificateUrl'] ?? '';
    final String fullUrl =
        rawUrl.startsWith('http') ? rawUrl : 'http://10.0.2.2:3001$rawUrl';
    return Certificate(
      courseName: json['courseName'],
      categoryId: json['categoryId'],
      issuedAt: json['issuedAt'],
      certificateUrl: fullUrl,
    );
  }
}
