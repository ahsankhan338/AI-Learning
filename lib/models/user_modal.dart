class User {
  final String name;
  final String email;
  final String? token;

  User({
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['displayName'] ?? 'Unknown User',
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? token,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': name,
        'email': email,
        'token': token,
      };
}
