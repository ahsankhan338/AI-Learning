class QuizTitle {
  final String title;
  final String status; // "locked", "unlocked", "passed", "failed"

  QuizTitle({
    required this.title,
    required this.status,
  });

  factory QuizTitle.fromJson(Map<String, dynamic> json) {
    return QuizTitle(
      title: json['title'] ?? '',
      status: json['status'] ?? 'locked',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
    };
  }
}

class UserQuiz {
  final String id;
  final String userId;
  final String categoryId;
  final List<QuizTitle> titles;
  final String createdAt;

  UserQuiz({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.titles,
    required this.createdAt,
  });

  factory UserQuiz.fromJson(Map<String, dynamic> json) {
    return UserQuiz(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      titles: (json['titles'] as List?)
              ?.map((title) => QuizTitle.fromJson(title))
              ?.toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
    );
  }
} 