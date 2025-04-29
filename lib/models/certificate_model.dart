class Certificate {
  final String courseName;
  final String categoryId;
  final String issuedAt;

  Certificate({
    required this.courseName,
    required this.categoryId,
    required this.issuedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      courseName: json['courseName'],
      categoryId: json['categoryId'],
      issuedAt: json['issuedAt'],
    );
  }
}
