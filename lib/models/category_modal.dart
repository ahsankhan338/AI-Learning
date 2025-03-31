class Category {
  final String uuid;
  final String title;
  final String imageUrl;

  Category({
    required this.uuid,
    required this.title,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      uuid: json['uuid'] as String,
      title: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Category(uuid: $uuid, title: $title, imageUrl: $imageUrl)';
  }
}
